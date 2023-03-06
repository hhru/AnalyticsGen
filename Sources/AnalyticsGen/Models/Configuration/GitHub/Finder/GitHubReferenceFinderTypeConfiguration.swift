import Foundation

enum GitHubReferenceFinderTypeConfiguration: Equatable {
    case matchedTag(source: FinderSourceConfiguration, branchRegex: String)
    case lastMerged(branch: String?, mergeCommitCount: Int, branchRegex: String)
    case lastTag
    case lastCommit(branch: String)
}
