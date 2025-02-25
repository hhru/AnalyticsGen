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
    
    func fetchRepo(owner: String, repo: String, ref: String, token: String, key: String) -> Promise<URL> {
        perform(on: .global()) {
            Log.debug("Checking out source code from Forgejo...")

            let gitCachePath = FileManager.default
                .homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Caches/ru.hh.analyticsgen/git")
                .path

            let host = try baseURL.host.throwing()
            let gitRepositoryURL = "git@\(host):\(owner)/\(repo).git"

            if !FileManager.default.directoryExists(atPath: gitCachePath) {
                Log.debug("Creating a reference repository...")
                try shell("git clone --depth 1 --filter=blob:none --filter=tree:0 \(gitRepositoryURL) \(gitCachePath)")
            } else {
                Log.debug("Updating a reference repository...")
                try shell("cd \(gitCachePath) && git fetch origin \(ref)")
            }

            let repositoryPathURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(repo)-\(key)")
            let repositoryPath = repositoryPathURL.path

            if FileManager.default.directoryExists(atPath: repositoryPath) {
                Log.debug("Cleaning repository directory...")
                try FileManager.default.removeItem(atPath: repositoryPath)
            }

            Log.debug("Cloning repository...")
            try shell("git clone --reference \(gitCachePath) \(gitRepositoryURL) \(repositoryPath)")

            Log.debug("Checking out \(ref) branch...")
            try shell("cd \(repositoryPath) && git checkout \(ref)")

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
