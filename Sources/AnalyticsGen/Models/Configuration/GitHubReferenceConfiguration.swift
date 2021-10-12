import Foundation

enum GitHubReferenceConfiguration: Decodable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case branch
        case tag
    }

    // MARK: - Enumeration Cases

    case branch(String)
    case tag(String)

    // MARK: - Instance Properties

    var name: String {
        switch self {
        case .branch(let name), .tag(let name):
            return name
        }
    }

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let branchName = try container.decodeIfPresent(String.self, forKey: .branch) {
            self = .branch(branchName)
        } else if let tagName = try container.decodeIfPresent(String.self, forKey: .tag) {
            self = .tag(tagName)
        } else {
            throw DecodingError.typeMismatch(
                GitHubReferenceConfiguration.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid reference, expected 'branch' or 'tag'",
                    underlyingError: nil
                )
            )
        }
    }
}
