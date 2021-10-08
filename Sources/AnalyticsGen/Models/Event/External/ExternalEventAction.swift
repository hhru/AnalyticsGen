import Foundation

enum ExternalEventAction: Decodable {

    // MARK: - Enumeration Cases

    case string(String)
    case property(ExternalEventProperty)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let string = try? String(from: decoder) {
            self = .string(string)
        } else {
            self = .property(try ExternalEventProperty(from: decoder))
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
