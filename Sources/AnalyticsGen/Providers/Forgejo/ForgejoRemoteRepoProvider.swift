import Foundation
import PromiseKit
import AnalyticsGenTools
import ZIPFoundation

struct ForgejoRemoteRepoProvider: RemoteRepoProvider {
    
    // MARK: - Instance Properties
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
        let downloadURL = baseURL
            .appendingPathComponent("repos")
            .appendingPathComponent(owner)
            .appendingPathComponent(repo)
            .appendingPathComponent("archive")
            .appendingPathComponent("\(ref).zip")
        
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
