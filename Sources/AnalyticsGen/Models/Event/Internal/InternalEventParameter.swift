import Foundation

struct InternalEventParameter: Codable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case name
        case description
        case nullable
        case type
    }

    // MARK: - Instance Properties

    let name: String
    let description: String?
    let nullable: Bool
    let type: InternalEventParameterType

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard let name = decoder.codingPath.last?.stringValue else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Failed decode 'name' from CodingPath"
                )
            )
        }

        self.name = name
        self.description = try container.decodeIfPresent(forKey: .description)
        self.nullable = try container.decodeIfPresent(forKey: .nullable) ?? false
        self.type = try InternalEventParameterType(from: decoder)
    }
}
