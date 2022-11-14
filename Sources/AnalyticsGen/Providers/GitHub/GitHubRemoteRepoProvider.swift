import Foundation
import PromiseKit
import AnalyticsGenTools
import ZIPFoundation

struct GitHubRemoteRepoProvider: RemoteRepoProvider {

    // MARK: - Instance Properties

    let httpService: HTTPService

    // MARK: - RemoteRepoProvider

    func fetchRepo(owner: String, repo: String, ref: String, token: String, key: String) -> Promise<URL> {
        guard let downloadURL = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/zipball/\(ref)") else {
            return .error(HTTPError(code: .badRequest, reason: "Invalid url"))
        }

        return Promise { seal in
            httpService
                .downloadRequest(
                    route: HTTPRoute(
                        method: .get,
                        url: downloadURL,
                        headers: [.authorization(bearerToken: token)]
                    )
                )
                .responseData { httpResponse in
                    switch httpResponse.result {
                    case .success(let data):
                        let fileManager = FileManager.default

                        let archiveFileURL = fileManager
                            .temporaryDirectory
                            .appendingPathComponent("remote-schemas-\(key).zip")

                        let destinationPathURL = fileManager
                            .temporaryDirectory
                            .appendingPathComponent("remote-schema-\(key)")

                        do {
                            try data.write(to: archiveFileURL)
                            try? fileManager.removeItem(at: destinationPathURL)
                            try fileManager.createDirectory(at: destinationPathURL, withIntermediateDirectories: true)
                            try fileManager.unzipItem(at: archiveFileURL, to: destinationPathURL)

                            let repoPathURL = try fileManager.contentsOfDirectory(
                                at: destinationPathURL,
                                includingPropertiesForKeys: nil
                            )

                            seal.fulfill(repoPathURL[0])
                        } catch {
                            seal.reject(error)
                        }

                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }

    func fetchReference(owner: String, repo: String, ref: String, token: String) -> Promise<GitReference> {
        guard let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/git/ref/\(ref)") else {
            return .error(HTTPError(code: .badRequest, reason: "Invalid url"))
        }

        return Promise { seal in
            httpService
                .request(
                    route: HTTPRoute(
                        method: .get,
                        url: url,
                        headers: [.authorization(bearerToken: token)]
                    )
                )
                .responseDecodable(type: GitReference.self) { httpResponse in
                    switch httpResponse.result {
                    case .success(let reference):
                        seal.fulfill(reference)

                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
}
