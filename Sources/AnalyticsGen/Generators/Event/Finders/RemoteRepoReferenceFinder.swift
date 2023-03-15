import Foundation
import PromiseKit
import AnalyticsGenTools

final class RemoteRepoReferenceFinder {

    private let remoteRepoProvider: RemoteRepoProvider

    init(remoteRepoProvider: RemoteRepoProvider) {
        self.remoteRepoProvider = remoteRepoProvider
    }

    private func matches(for regex: String, in text: String) throws -> [String] {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        return results.map { result in
            String(
                text[Range(result.range, in: text)!]
            )
        }
    }

    private func lastMergeCommits(branch: String?, mergeCommitCount: Int) throws -> String {
        if let branch {
            return try shell("git log --merges origin/\(branch) --oneline -\(mergeCommitCount)")
        } else {
            return try shell("git log --merges --oneline -\(mergeCommitCount)")
        }
    }

    private func findReference(
        configuration: GitHubReferenceFinderConfiguration,
        gitHubConfiguration: GitHubSourceConfiguration,
        tags: [String]
    ) throws -> GitReferenceType? {
        guard try configuration.runCondition?.isSatisfyCondition() ?? true else {
            return nil
        }

        switch configuration.type {
        case let .matchedTag(source, branchRegex):
            return try source
                .satisfiedValue()
                .flatMap { value in
                    try tags
                        .first(where: { tag in
                            guard let taggedBranch = try matches(for: branchRegex, in: tag).first else {
                                return false
                            }

                            return taggedBranch == value
                        })
                        .map { .tag(name: $0) }
                }

        case let .lastMerged(branch, mergeCommitCount, branchRegex):
            let lastMergeCommits = try lastMergeCommits(branch: branch, mergeCommitCount: mergeCommitCount)
            let lastMergedBranches = try matches(for: branchRegex, in: lastMergeCommits)
            let taggedBranches = try tags.flatMap { try matches(for: branchRegex, in: $0) }

            return lastMergedBranches
                .lazy
                .compactMap { branch in
                    guard let tagIndex = taggedBranches.firstIndex(of: branch) else {
                        return nil
                    }

                    return tags[tagIndex]
                }
                .first
                .map { .tag(name: $0) }

        case .lastTag:
            return tags
                .first
                .map { .tag(name: $0) }

        case .lastCommit(let branch):
            return try remoteRepoProvider
                .fetchLastCommitSHA(
                    owner: gitHubConfiguration.owner,
                    repo: gitHubConfiguration.repo,
                    branch: branch,
                    token: try gitHubConfiguration.accessToken.resolveToken()
                )
                .map { .commit(sha: $0) }
                .wait()
        }
    }

    func findReference(
        configurations: [GitHubReferenceFinderConfiguration],
        gitHubConfiguration: GitHubSourceConfiguration
    ) throws -> Promise<GitReferenceType?> {
        remoteRepoProvider
            .fetchTagList(
                owner: gitHubConfiguration.owner,
                repo: gitHubConfiguration.repo,
                count: 100,
                token: try gitHubConfiguration.accessToken.resolveToken()
            )
            .map(on: .global()) { tags in
                try configurations
                    .enumerated()
                    .mapFirst { index, configuration in
                        let gitRefenceType = try self.findReference(
                            configuration: configuration,
                            gitHubConfiguration: gitHubConfiguration,
                            tags: tags
                        )

                        Log.debug("[Finder-\(index)] found git reference: '\(optional: gitRefenceType?.rawValue)'")

                        return gitRefenceType
                    }
            }
    }
}
