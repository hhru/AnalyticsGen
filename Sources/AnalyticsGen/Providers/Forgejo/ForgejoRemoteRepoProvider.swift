import Foundation
import AnalyticsGenTools
import ZIPFoundation

struct ForgejoRemoteRepoProvider: RemoteRepoProvider {

    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func fetchRepo(owner: String, repo: String, ref: GitReferenceType, token: String) async throws -> URL {
        Log.debug("Checking out source code from Forgejo...")

        let host = try baseURL.host.throwing()
        let gitRepositoryURL = "git@\(host):\(owner)/\(repo).git"

        let tempURL = FileManager.default.temporaryDirectory
        let privateTempURL = URL(fileURLWithPath: "/private" + tempURL.path)

        let repositoryPathURL = privateTempURL.appendingPathComponent(repo)
        let repositoryPath = repositoryPathURL.path

        if FileManager.default.directoryExists(atPath: repositoryPath) {
            Log.debug("Cleaning repository directory...")
            try FileManager.default.removeItem(atPath: repositoryPath)
        }

        Log.debug("Cloning repository...")
        switch ref {
        case .tag(let name), .branch(let name):
            try shell("git clone -b \(name) \(gitRepositoryURL) \(repositoryPath)")

        case .commit(let sha):
            try shell("git clone \(gitRepositoryURL) \(repositoryPath)")

            Log.debug("Checking out \(sha) commit...")
            try shell("cd \(repositoryPath) && git checkout \(sha)")
        }

        return repositoryPathURL
    }
}
