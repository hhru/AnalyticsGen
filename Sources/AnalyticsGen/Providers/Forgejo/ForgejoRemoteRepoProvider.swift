import AnalyticsGenTools
import Foundation
import PathKit
import ZIPFoundation

struct ForgejoRemoteRepoProvider {

    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    /// Создает и обновляет локальный Git кэш для ускорения клонирования
    /// - Parameters:
    ///   - gitRepositoryURL: URL Git репозитория
    ///   - owner: Владелец репозитория
    ///   - repo: Название репозитория
    /// - Returns: Путь к директории кэша
    private func setupAndUpdateGitCache(
        gitRepositoryURL: String,
        owner: String,
        repo: String
    ) throws -> Path {
        let gitCachePath = Path.home
            .appending("Library/Caches/ru.hh.analyticsgen/git")
            .appending(owner)
            .appending("\(repo).git")

        if !gitCachePath.exists {
            Log.debug("Creating Git cache repository at \(gitCachePath)...")

            try gitCachePath.parent().mkpath()

            try shell("git clone --bare \(gitRepositoryURL) \(gitCachePath)")
        }

        Log.debug("Updating Git cache repository...")
        try shell("cd \(gitCachePath) && git fetch --all --tags --prune")

        return gitCachePath
    }
}

extension ForgejoRemoteRepoProvider: RemoteRepoProvider {

    func fetchRepo(owner: String, repo: String, ref: GitReferenceType, token: String) async throws -> URL {
        Log.debug("Checking out source code from Forgejo...")

        let host = try baseURL.host.throwing()
        let gitRepositoryURL = "git@\(host):\(owner)/\(repo).git"

        let repositoryPath = Path("/private")
            .appending(FileManager.default.temporaryDirectory.path)
            .appending(repo)

        if repositoryPath.exists {
            Log.debug("Cleaning repository directory...")
            try repositoryPath.delete()
        }

        let gitCachePath = try setupAndUpdateGitCache(
            gitRepositoryURL: gitRepositoryURL,
            owner: owner,
            repo: repo
        )

        Log.debug("Cloning repository with cache reference...")
        switch ref {
        case let .tag(name), let .branch(name):
            try shell("git clone --reference \(gitCachePath) -b \(name) \(gitRepositoryURL) \(repositoryPath)")

        case let .commit(sha):
            try shell("git clone --reference \(gitCachePath) \(gitRepositoryURL) \(repositoryPath)")

            Log.debug("Checking out \(sha) commit...")
            try shell("cd \(repositoryPath) && git checkout \(sha)")
        }

        return repositoryPath.url
    }
}
