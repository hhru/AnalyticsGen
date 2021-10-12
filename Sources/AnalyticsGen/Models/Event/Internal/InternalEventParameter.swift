import Foundation

struct InternalEventParameter: Decodable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case name
        case description
        case nullable
        case type
    }

    // MARK: -

    enum KnownName: String {

        // MARK: - Enumeration Cases

        case screenName
        case hhtmSource
        case hhtmFrom
    }

    // MARK: - Instance Properties

    let name: String
    let description: String?
    let type: InternalEventParameterType

    // MARK: -

    var knownName: KnownName? {
        KnownName(rawValue: name)
    }

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
        self.type = try InternalEventParameterType(from: decoder)
    }
}
