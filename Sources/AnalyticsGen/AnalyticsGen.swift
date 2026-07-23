import ArgumentParser
import Foundation
import PathKit
import AnalyticsGenTools

@main
struct AnalyticsGen: AsyncParsableCommand {

    struct Generate: AsyncParsableCommand {

        /// Контекст открытого iOS Autogen-PR для post-generation шага (auto-merge при пустой генерации).
        private struct AutogenContext {
            let opener: AutogenPullRequestOpener
            let owner: String
            let repo: String
            let prNumber: Int
        }

        static var configuration = CommandConfiguration(
            abstract: "Generate Swift analytics events code from YAML schemas"
        )

        @Option(name: [.short, .long], help: "Path to the configuration file")
        var config: String = ".analyticsGen.yml"

        @Flag(help: "Enable debug logging")
        var debug: Bool = false

        @Option(name: [.short, .long], help: "Specify branch name for remote repository (overrides default branch)")
        var branch: String?

        func run() async throws {
            #if DEBUG
            if let currentPath = ProcessInfo.processInfo.environment["CURRENT_PATH"] {
                Path.current = Path(currentPath)
            } else {
                Path.current = Path(#file).appending("../../../Example")
            }
            #endif

            Log.isDebugLoggingEnabled = debug

            if branch != nil {
                try Git.ensureGitRepository()
            }

            let fileProvider = Dependencies.yamlFileProvider
            let generator = Dependencies.eventGenerator

            let configuration = try fileProvider.readFile(at: config, type: Configuration.self)

            if let branch {
                try Git.checkNoForeignAnalyticsTags(branch: branch, baseBranch: .baseBranch)
            }

            var autogenContext: AutogenContext?

            if let branch, let repoConfiguration = configuration.source.remoteRepoConfiguration {
                let opener = try makeAutogenPullRequestOpener(repoConfiguration: repoConfiguration)
                let suffix = repoConfiguration.branchSuffix

                let prNumber = try await opener.ensurePullRequest(
                    owner: repoConfiguration.owner,
                    repo: repoConfiguration.repo,
                    analystBranch: branch,
                    platformBranch: "\(branch)-\(suffix)",
                    baseBranch: "\(repoConfiguration.defaultBranch)-\(suffix)"
                )

                autogenContext = AutogenContext(
                    opener: opener,
                    owner: repoConfiguration.owner,
                    repo: repoConfiguration.repo,
                    prNumber: prNumber
                )
            }

            try await generator.generate(configuration: configuration, branch: branch)

            Log.info("Generation completed successfully!")

            if let branch {
                try await handlePostGeneration(
                    branch: branch,
                    destinations: configuration.destinations,
                    autogenContext: autogenContext
                )
            }
        }

        private func makeAutogenPullRequestOpener(
            repoConfiguration: RemoteRepoSourceConfiguration
        ) throws -> AutogenPullRequestOpener {
            let token = try repoConfiguration.accessToken.resolveToken()

            let client = ForgejoAPIClient(
                baseURL: Dependencies.forgejoAPIBaseURL,
                httpService: Dependencies.httpService,
                token: token
            )

            return AutogenPullRequestOpener(service: client)
        }

        private func handlePostGeneration(
            branch: String,
            destinations: [String],
            autogenContext: AutogenContext?
        ) async throws {
            guard !destinations.isEmpty else {
                Log.info("No analytics destinations configured, skipping commit")
                return
            }

            let changedPaths = try Git.changedPaths(in: destinations)

            if !changedPaths.isEmpty {
                guard try Git.currentBranch() != .baseBranch else {
                    Log.info(
                        """
                        ⚠️ Generated changes detected, but the current branch is '\(String.baseBranch)' — \
                        commit, tag and push are skipped. Changes are left in the working copy. \
                        Review the diff and rerun from a feature branch if needed.
                        """
                    )
                    return
                }

                try commitAndTag(branch: branch, changedPaths: changedPaths)
                return
            }

            guard let autogenContext else {
                Log.info("No iOS changes generated and no Autogen-PR to merge, skipping")
                return
            }

            guard try !Git.hasBranchCommits(in: destinations, baseBranch: .baseBranch) else {
                Log.info(
                    """
                    iOS changes were already committed on this branch earlier — \
                    leaving Autogen-PR #\(autogenContext.prNumber) open for review
                    """
                )
                return
            }

            Log.info("No iOS changes generated — auto-merging Autogen-PR #\(autogenContext.prNumber)")

            try await autogenContext.opener.autoMergeAutogenPullRequest(
                owner: autogenContext.owner,
                repo: autogenContext.repo,
                number: autogenContext.prNumber
            )
        }

        private func commitAndTag(branch: String, changedPaths: [String]) throws {
            Log.info("Analytics paths to commit: \(changedPaths.joined(separator: ", "))")

            let commitMessage = "Сгенерированы события аналитики из ветки: \(branch)"
            let tagPrefix = "analytics/\(branch)"
            let nextIndex = try Git.getNextTagIndex(for: tagPrefix)
            let tagName = "\(tagPrefix)-\(nextIndex)"
            try Git.commitAndTag(message: commitMessage, tag: tagName, paths: changedPaths)
            try Git.pushTag(tagName)

            Log.info("Successfully created local commit and pushed tag '\(tagName)'")
        }
    }

    struct Version: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display the current version of AnalyticsGen"
        )

        func run() throws {
            print(String.version)
        }
    }

    static let configuration = CommandConfiguration(
        abstract: "A code generation tool for creating type-safe analytics events from YAML schemas",
        subcommands: [Generate.self, Version.self]
    )
}

private extension String {
    static let version = "1.2.0"

    /// Базовая ветка consumer-репозитория: от неё считаются чужие теги аналитики,
    /// и на ней запрещены commit/tag/push результатов генерации.
    static let baseBranch = "develop"
}
