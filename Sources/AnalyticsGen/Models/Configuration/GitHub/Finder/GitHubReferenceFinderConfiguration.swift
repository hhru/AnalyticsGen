import Foundation

struct GitHubReferenceFinderConfiguration: Decodable, Equatable {

    let type: GitHubReferenceFinderTypeConfiguration
    let runCondition: FinderSourceConfiguration?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(RawType.self, forKey: .type)

        switch rawType {
        case .matchedTag:
            self.type = .matchedTag(
                source: try container.decode(forKey: .source),
                branchRegex: try container.decode(forKey: .branchRegex)
            )

        case .lastMerged:
            self.type = .lastMerged(
                branch: try container.decode(forKey: .branch),
                mergeCommitCount: try container.decode(forKey: .mergeCommitCount),
                branchRegex: try container.decode(forKey: .branchRegex)
            )

        case .lastTag:
            self.type = .lastTag

        case .lastCommit:
            self.type = .lastCommit(
                branch: try container.decode(forKey: .branch)
            )
        }

        self.runCondition = try container
            .decodeIfPresent(RunCondition.self, forKey: .runCondition)?
            .source
    }
}

extension GitHubReferenceFinderConfiguration {

    private enum CodingKeys: String, CodingKey {
        case type
        case source
        case branch
        case mergeCommitCount = "merge_commit_count"
        case branchRegex = "branch_regex"
        case runCondition = "run_condition"
    }

    private enum RawType: String, Decodable {
        case matchedTag = "matched_tag"
        case lastMerged = "last_merged"
        case lastTag = "last_tag"
        case lastCommit = "last_commit"
    }

    private struct RunCondition: Decodable {
        let source: FinderSourceConfiguration
    }
}
