import Foundation
import PromiseKit
import AnalyticsGenTools
import ZIPFoundation

struct GitHubRemoteRepoProvider: RemoteRepoProvider {

    // MARK: - Instance Properties

    private let baseURL = URL(string: "https://api.github.com")!

    // MARK: -

    let httpService: HTTPService

    // MARK: - RemoteRepoProvider

    func fetchRepo(owner: String, repo: String, ref: String, token: String, key: String) -> Promise<URL> {
        let downloadURL = baseURL
            .appendingPathComponent("repos")
            .appendingPathComponent(owner)
            .appendingPathComponent(repo)
            .appendingPathComponent("zipball")
            .appendingPathComponent(ref)

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
        let refURL = baseURL
            .appendingPathComponent("repos")
            .appendingPathComponent(owner)
            .appendingPathComponent(repo)
            .appendingPathComponent("git/ref")
            .appendingPathComponent(ref)

        return Promise { seal in
            httpService
                .request(
                    route: HTTPRoute(
                        method: .get,
                        url: refURL,
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

    func fetchTagList(owner: String, repo: String, count: Int, token: String) -> Promise<[String]> {
        let requestURL = baseURL.appendingPathComponent("graphql")

        let query = """
        {
          repository(owner: "\(owner)", name: "\(repo)") {
            refs(refPrefix: "refs/tags/", first: \(count), orderBy: {field: TAG_COMMIT_DATE, direction: DESC}) {
              edges {
                node {
                  name
                }
              }
            }
          }
        }
        """

        return Promise { seal in
            httpService
                .request(
                    route: HTTPRoute(
                        method: .post,
                        url: requestURL,
                        headers: [.authorization(bearerToken: token)],
                        bodyParameters: GitHubPayload(query: query)
                    )
                )
                .responseDecodable(type: GitHubAPIResponse<GitHubQuery>.self) { httpResponse in
                    switch httpResponse.result {
                    case .success(let response):
                        seal.fulfill(response.data.repository.refs.edges.map { $0.node.name })

                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }

    func fetchLastCommitSHA(owner: String, repo: String, branch: String, token: String) -> Promise<String> {
        let lastCommitURL = baseURL
            .appendingPathComponent("repos")
            .appendingPathComponent(owner)
            .appendingPathComponent(repo)
            .appendingPathComponent("commits")
            .appendingPathComponent(branch)

        return Promise { seal in
            httpService
                .request(
                    route: HTTPRoute(
                        method: .get,
                        url: lastCommitURL,
                        headers: [.authorization(bearerToken: token)]
                    )
                )
                .responseDecodable(type: GitHubCommit.self) { httpResponse in
                    switch httpResponse.result {
                    case .success(let commit):
                        seal.fulfill(commit.sha)

                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
}
