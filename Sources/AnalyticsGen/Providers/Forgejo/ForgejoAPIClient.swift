import Foundation
import AnalyticsGenTools

struct ForgejoAPIClient {

    private struct CreatePullRequestBody: Encodable {
        let base: String
        let head: String
        let title: String
        let body: String
        let labels: [Int]
    }

    private struct MergePullRequestBody: Encodable {
        let method: String
        let mergeWhenChecksSucceed: Bool
        let deleteBranchAfterMerge: Bool

        private enum CodingKeys: String, CodingKey {
            case method = "Do"
            case mergeWhenChecksSucceed = "merge_when_checks_succeed"
            case deleteBranchAfterMerge = "delete_branch_after_merge"
        }
    }

    private enum Constants {
        static let pageSize = 50
        static let maxRetries = 3
    }

    private let baseURL: URL
    private let httpService: HTTPService
    private let token: String

    private var headers: [HTTPHeader] {
        [
            .authorization("token \(token)"),
            .contentType("application/json")
        ]
    }

    init(baseURL: URL, httpService: HTTPService, token: String) {
        self.baseURL = baseURL
        self.httpService = httpService
        self.token = token
    }

    private func pullsURL(owner: String, repo: String) -> URL {
        baseURL.appendingPathComponent("repos/\(owner)/\(repo)/pulls")
    }

    private func send<T: Decodable>(
        route: HTTPRoute,
        retryOnTransient: Bool,
        decodeTo type: T.Type
    ) async throws -> T {
        var attempt = 0

        while true {
            let response = await httpService.request(route: route).responseData()

            switch response.result {
            case let .success(data):
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    throw MessageError("Forgejo: failed to decode response for \(route): \(error)")
                }

            case let .failure(error):
                attempt += 1

                if retryOnTransient, Self.isTransient(error), attempt < Constants.maxRetries {
                    Log.info("Forgejo: transient error (\(error)), retry \(attempt)/\(Constants.maxRetries)...")
                    continue
                }

                let body = error.data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                throw MessageError("Forgejo: request \(route) failed with \(error). \(body)")
            }
        }
    }

    /// Отправляет запрос, для которого успех — любой 2xx с пустым телом (ответ не декодируется).
    /// - Throws: `ForgejoMergeError.rejected` с HTTP-кодом и телом при отказе сервера;
    ///   `MessageError` при сетевой ошибке без HTTP-статуса.
    private func sendExpectingNoContent(route: HTTPRoute, retryOnTransient: Bool) async throws {
        let serializer = HTTPDataResponseSerializer(emptyResponseStatusCodes: [200, 201, 202, 204, 205])
        var attempt = 0

        while true {
            let response = await httpService.request(route: route).response(serializer: serializer)

            switch response.result {
            case .success:
                return

            case let .failure(error):
                attempt += 1

                if retryOnTransient, Self.isTransient(error), attempt < Constants.maxRetries {
                    Log.info("Forgejo: transient error (\(error)), retry \(attempt)/\(Constants.maxRetries)...")
                    continue
                }

                let body = error.data.flatMap { String(data: $0, encoding: .utf8) } ?? ""

                guard let statusCode = error.statusCode else {
                    throw MessageError("Forgejo: request \(route) failed with \(error). \(body)")
                }

                throw ForgejoMergeError.rejected(code: statusCode.rawValue, body: body)
            }
        }
    }

    private static func isTransient(_ error: HTTPError) -> Bool {
        switch error.code {
        case .server, .tooManyRequests, .timedOut, .networkConnection:
            return true

        default:
            return false
        }
    }
}

// MARK: - ForgejoPullRequestService

extension ForgejoAPIClient: ForgejoPullRequestService {

    func findPullRequest(
        owner: String,
        repo: String,
        head: String,
        base: String?,
        state: String
    ) async throws -> PullRequestInfo? {
        try await firstPull(owner: owner, repo: repo, state: state) { pull in
            pull.head.ref == head && (base == nil || pull.base.ref == base)
        }
    }

    func findAnalystPullRequest(
        owner: String,
        repo: String,
        branch: String
    ) async throws -> PullRequestInfo? {
        try await firstPull(owner: owner, repo: repo, state: "all") { pull in
            (pull.state == .open || pull.merged == true) && pull.headMatches(branch: branch)
        }
    }

    /// Постранично перебирает PR в состоянии `state` и возвращает первый, удовлетворяющий `predicate`.
    private func firstPull(
        owner: String,
        repo: String,
        state: String,
        where predicate: (PullRequestInfo) -> Bool
    ) async throws -> PullRequestInfo? {
        var page = 1

        while true {
            let route = HTTPRoute(
                method: .get,
                url: pullsURL(owner: owner, repo: repo),
                headers: headers,
                queryParameters: [
                    "state": state,
                    "page": String(page),
                    "limit": String(Constants.pageSize)
                ]
            )

            let pulls: [PullRequestInfo] = try await send(
                route: route,
                retryOnTransient: true,
                decodeTo: [PullRequestInfo].self
            )

            if let match = pulls.first(where: predicate) {
                return match
            }

            if pulls.isEmpty {
                return nil
            }

            page += 1
        }
    }

    func createPullRequest(
        owner: String,
        repo: String,
        head: String,
        base: String,
        title: String,
        body: String,
        labels: [Int]
    ) async throws -> Int {
        let route = HTTPRoute(
            method: .post,
            url: pullsURL(owner: owner, repo: repo),
            headers: headers,
            bodyParameters: CreatePullRequestBody(
                base: base,
                head: head,
                title: title,
                body: body,
                labels: labels
            )
        )

        // POST не ретраим, чтобы не создать дубль PR при ответе 5xx после фактического создания.
        let created: PullRequestInfo = try await send(
            route: route,
            retryOnTransient: false,
            decodeTo: PullRequestInfo.self
        )

        return created.number
    }

    func getPullRequest(
        owner: String,
        repo: String,
        number: Int
    ) async throws -> PullRequestInfo {
        let route = HTTPRoute(
            method: .get,
            url: pullsURL(owner: owner, repo: repo).appendingPathComponent("\(number)"),
            headers: headers
        )

        return try await send(route: route, retryOnTransient: true, decodeTo: PullRequestInfo.self)
    }

    func getCommitStatus(
        owner: String,
        repo: String,
        ref: String
    ) async throws -> CommitCombinedStatus {
        let route = HTTPRoute(
            method: .get,
            url: baseURL.appendingPathComponent("repos/\(owner)/\(repo)/commits/\(ref)/status"),
            headers: headers
        )

        return try await send(route: route, retryOnTransient: true, decodeTo: CommitCombinedStatus.self)
    }

    func scheduleMerge(
        owner: String,
        repo: String,
        number: Int,
        method: String,
        deleteBranchAfterMerge: Bool
    ) async throws {
        let route = HTTPRoute(
            method: .post,
            url: pullsURL(owner: owner, repo: repo).appendingPathComponent("\(number)/merge"),
            headers: headers,
            bodyParameters: MergePullRequestBody(
                method: method,
                mergeWhenChecksSucceed: true,
                deleteBranchAfterMerge: deleteBranchAfterMerge
            )
        )

        try await sendExpectingNoContent(route: route, retryOnTransient: false)
    }
}
