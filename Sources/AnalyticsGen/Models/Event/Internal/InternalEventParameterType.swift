import Foundation

enum InternalEventParameterType: Codable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case const
        case oneOf
        case type
    }

    // MARK: - Enumeration Cases

    case const(String)
    case oneOf([OneOf])
    case type(String)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let const = try container.decodeIfPresent(String.self, forKey: .const) {
            self = .const(const)
        } else if let oneOf: [OneOf] = try container.decodeIfPresent(forKey: .oneOf) {
            self = .oneOf(oneOf)
        } else if let type = try container.decodeIfPresent(String.self, forKey: .type) {
            self = .type(type)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unexpected internal parameter"
                )
            )
        }
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .const(let value):
            try container.encode(value, forKey: .const)

        case .oneOf(let variants):
            try container.encode(variants, forKey: .oneOf)

        case .type(let name):
            try container.encode(name, forKey: .type)
        }
    }
}
