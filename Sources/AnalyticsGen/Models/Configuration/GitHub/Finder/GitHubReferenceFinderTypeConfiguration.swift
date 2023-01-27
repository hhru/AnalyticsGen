import Foundation

enum GitHubReferenceFinderTypeConfiguration: Equatable {
    case matchedTag(source: FinderSourceConfiguration)
    case lastMerged(branch: String, condition: FinderConditionConfiguration)
    case lastTag
    case lastCommit(branch: String)
}
