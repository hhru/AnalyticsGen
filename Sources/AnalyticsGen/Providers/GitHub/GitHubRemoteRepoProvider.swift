import Foundation
import PromiseKit
import AnalyticsGenTools
import ZIPFoundation

struct GitHubRemoteRepoProvider: RemoteRepoProvider {

    // MARK: - Instance Properties

    let httpService: HTTPService

    // MARK: - Instance Methods

    private func basicAuthValue(username: String, token: String) -> String {
        let base64Login = String(format: "%@:%@", username, token).data(using: .utf8)!.base64EncodedString()

        return "Basic \(base64Login)"
    }

    // MARK: -

    func fetchRepo(owner: String, repo: String, branch: String, username: String, token: String) -> Promise<URL> {
        guard let downloadURL = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/zipball/\(branch)") else {
            return .error(HTTPError(code: .badRequest, reason: "Invalid url"))
        }

        return Promise { seal in
            httpService
                .downloadRequest(
                    route: HTTPRoute(
                        method: .get,
                        url: downloadURL,
                        headers: [
                            HTTPHeader(name: "Authorization", value: basicAuthValue(username: username, token: token))
                        ]
                    )
                )
                .responseData { httpResponse in
                    switch httpResponse.result {
                    case .success(let data):
                        let fileManager = FileManager.default
                        let archiveFileURL = fileManager.temporaryDirectory.appendingPathComponent("remote-schemas.zip")
                        let destinationPathURL = fileManager.temporaryDirectory.appendingPathComponent("remote-schema")

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
}
