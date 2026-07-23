@testable import AnalyticsGen

final class MockForgejoPullRequestService: ForgejoPullRequestService {

    struct CreateCall: Equatable {
        let owner: String
        let repo: String
        let head: String
        let base: String
        let title: String
        let body: String
        let labels: [Int]
    }

    /// Ответы на последовательные вызовы findPullRequest (по порядку).
    var findResults: [PullRequestInfo?] = []
    private(set) var findIndex = 0
    private(set) var findCalls: [(head: String, base: String?)] = []

    /// Результат findAnalystPullRequest.
    var analystResult: PullRequestInfo?
    private(set) var analystBranchCalls: [String] = []

    private(set) var createCalls: [CreateCall] = []
    var createResult = 777

    func findPullRequest(owner: String, repo: String, head: String, base: String?, state: String) async throws -> PullRequestInfo? {
        findCalls.append((head, base))
        defer { findIndex += 1 }
        return findIndex < findResults.count ? findResults[findIndex] : nil
    }

    func findAnalystPullRequest(owner: String, repo: String, branch: String) async throws -> PullRequestInfo? {
        analystBranchCalls.append(branch)
        return analystResult
    }

    func createPullRequest(owner: String, repo: String, head: String, base: String, title: String, body: String, labels: [Int]) async throws -> Int {
        createCalls.append(
            CreateCall(owner: owner, repo: repo, head: head, base: base, title: title, body: body, labels: labels)
        )
        return createResult
    }

    /// Ответы на последовательные вызовы getPullRequest (по порядку); последний повторяется.
    var pullResults: [PullRequestInfo] = []
    private(set) var getPullCalls: [Int] = []

    /// Ответы на последовательные вызовы getCommitStatus (по порядку); последний повторяется.
    var statusResults: [CommitCombinedStatus] = []
    private(set) var statusCalls: [String] = []

    /// Ошибка, которую бросит scheduleMerge (nil — успех).
    var scheduleMergeError: Error?
    private(set) var scheduleMergeCalls: [(number: Int, method: String, deleteBranchAfterMerge: Bool)] = []

    func getPullRequest(owner: String, repo: String, number: Int) async throws -> PullRequestInfo {
        precondition(!pullResults.isEmpty, "pullResults must be configured before calling getPullRequest")
        getPullCalls.append(number)
        return pullResults[min(getPullCalls.count - 1, pullResults.count - 1)]
    }

    func getCommitStatus(owner: String, repo: String, ref: String) async throws -> CommitCombinedStatus {
        precondition(!statusResults.isEmpty, "statusResults must be configured before calling getCommitStatus")
        statusCalls.append(ref)
        return statusResults[min(statusCalls.count - 1, statusResults.count - 1)]
    }

    func scheduleMerge(owner: String, repo: String, number: Int, method: String, deleteBranchAfterMerge: Bool) async throws {
        scheduleMergeCalls.append((number, method, deleteBranchAfterMerge))

        if let scheduleMergeError {
            throw scheduleMergeError
        }
    }
}
