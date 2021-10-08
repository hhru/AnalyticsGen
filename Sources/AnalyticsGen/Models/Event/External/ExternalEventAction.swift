import Foundation

enum ExternalEventAction: Decodable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case type
    }

    // MARK: - Enumeration Cases

    case string(String)
    case property(ExternalEventProperty)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let string = try? String(from: decoder) {
            self = .string(string)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self = .property(try container.decode(forKey: .type))
        }
    }
}

// MARK: -

extension ExternalEventAction {

    // MARK: - Instance Properties

    var description: String? {
        switch self {
        case .property(let property):
            return property.description

        case .string:
            return nil
        }
    }

    var value: String? {
        switch self {
        case .string(let value):
            return value

        case .property:
            return nil
        }
    }
}
