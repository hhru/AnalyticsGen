import Foundation

enum InternalEventConstantParameter: Codable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case hhtmSource
    }

    // MARK: - Enumeration Cases

    case string(String)
    case hhtmSource(String)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self = .hhtmSource(try container.decode(forKey: .hhtmSource))
        } else {
            self = .string(try String(from: decoder))
        }
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        switch self {
        case let .string(value):
            var container = encoder.singleValueContainer()
            try container.encode(value)

        case let .hhtmSource(value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .hhtmSource)
        }
    }
}
