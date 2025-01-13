import Foundation

enum RemoteRepoReferenceConfiguration: Decodable, Equatable {

    // MARK: - Enumeration Cases

    case branch(String)
    case tag(String)
    case finders([RemoteRepoReferenceFinderConfiguration])

    // MARK: - Instance Properties

    var name: String {
        switch self {
        case .branch(let name), .tag(let name):
            return name

        case .finders:
            fatalError("TODO: Вынести отсюда в следующей задаче")
        }
    }

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let branchName = try container.decodeIfPresent(String.self, forKey: .branch) {
            self = .branch(branchName)
        } else if let tagName = try container.decodeIfPresent(String.self, forKey: .tag) {
            self = .tag(tagName)
        } else if let finders = try container.decodeIfPresent([RemoteRepoReferenceFinderConfiguration].self, forKey: .finders) {
            self = .finders(finders)
        } else {
            throw DecodingError.typeMismatch(
                RemoteRepoReferenceConfiguration.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid reference, expected 'branch', 'tag' or 'finders'",
                    underlyingError: nil
                )
            )
        }
    }
}

extension RemoteRepoReferenceConfiguration {

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case branch
        case tag
        case finders
    }
}
