import Foundation

struct FinderSourceConfiguration: Decodable, Equatable {

    enum SourceType: Equatable {
        enum GitType: String, Decodable, Equatable {
            case currentBranchName = "current_branch_name"
        }

        case environment(variables: [String])
        case file(paths: [String])
        case git(type: GitType)
    }

    let type: SourceType
    let condition: FinderConditionConfiguration

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let variables = try container.decodeIfPresent([String].self, forKey: .env) {
            self.type = .environment(variables: variables)
        } else if let paths = try container.decodeIfPresent([String].self, forKey: .file) {
            self.type = .file(paths: paths)
        } else if let gitType = try container.decodeIfPresent(SourceType.GitType.self, forKey: .git) {
            self.type = .git(type: gitType)
        } else {
            throw DecodingError.typeMismatch(
                SourceType.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid source type, expected 'env' 'file' or 'git'",
                    underlyingError: nil
                )
            )
        }

        self.condition = try container.decode(forKey: .condition)
    }

    init(type: SourceType, condition: FinderConditionConfiguration) {
        self.type = type
        self.condition = condition
    }
}

extension FinderSourceConfiguration {

    private enum CodingKeys: String, CodingKey {
        case env
        case file
        case git
        case condition
    }
}
