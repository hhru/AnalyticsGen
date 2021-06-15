import Foundation

enum SourceConfiguration: Decodable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case gitHub
    }

    // MARK: - Instance Properties

    case local(path: String)
    case gitHub(configuration: GitHubSourceConfiguration)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self = .gitHub(configuration: try container.decode(forKey: .gitHub))
        } else {
            self = .local(path: try String(from: decoder))
        }
    }
}
