import Foundation
import PromiseKit
import AnalyticsGenTools
import ZIPFoundation

struct ForgejoRemoteRepoProvider: RemoteRepoProvider {

    let baseURL: URL
    let httpService: HTTPService

    init(
        baseURL: URL,
        httpService: HTTPService
    ) {
        self.baseURL = baseURL
        self.httpService = httpService
    }
    
    // MARK: - RemoteRepoProvider
    
    func fetchRepo(owner: String, repo: String, ref: GitReferenceType, token: String, key: String) -> Promise<URL> {
        perform(on: .global()) {
            Log.debug("Checking out source code from Forgejo...")

            let host = try baseURL.host.throwing()
            let gitRepositoryURL = "git@\(host):\(owner)/\(repo).git"

            let repositoryPathURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(repo)-\(key)")
            let repositoryPath = repositoryPathURL.path

            if FileManager.default.directoryExists(atPath: repositoryPath) {
                Log.debug("Cleaning repository directory...")
                try FileManager.default.removeItem(atPath: repositoryPath)
            }

            Log.debug("Cloning repository...")
            
            switch ref {
            case .tag, .branch:
                try shell("git clone --depth 1 -b \(ref.nameValue) \(gitRepositoryURL) \(repositoryPath)")

            case .commit:
                try shell("git clone \(gitRepositoryURL) \(repositoryPath)")

                Log.debug("Checking out \(ref.nameValue) branch...")
                try shell("cd \(repositoryPath) && git checkout \(ref.nameValue)")
            }

            return repositoryPathURL
        }
    }
    
    func fetchReference(owner: String, repo: String, ref: String, token: String) -> Promise<GitReference> {
        let refURL = baseURL
            .appendingPathComponent("repos")
            .appendingPathComponent(owner)
            .appendingPathComponent(repo)
            .appendingPathComponent("git/refs")
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
                .responseDecodable(type: [GitReference].self) { httpResponse in
                    switch httpResponse.result {
                    case .success(let result):
                        seal.fulfill(result[0])
                        
                    case .failure(let error):
                        seal.reject(error)
                    }
                }
        }
    }
    
    func fetchTagList(owner: String, repo: String, count: Int, token: String) -> Promise<[String]> {
        let requestURL = baseURL
            .appendingPathComponent("repos")
            .appendingPathComponent(owner)
            .appendingPathComponent(repo)
            .appendingPathComponent("tags")
        
        return Promise { seal in
            httpService
                .request(
                    route: HTTPRoute(
                        method: .get,
                        url: requestURL,
                        headers: [.authorization(bearerToken: token)],
                        queryParameters: ForgejoQueryCount(limit: count)
                    )
                )
                .responseDecodable(type: [ForgejoRef].self) { httpResponse in
                    switch httpResponse.result {
                    case .success(let response):
                        seal.fulfill(response.map { $0.name })
                        
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
            .appendingPathComponent("git/commits")
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
                .responseDecodable(type: ForgejoCommit.self) { httpResponse in
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
