import Foundation

enum ZarplataEventAction: Decodable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case oneOf
    }

    // MARK: - Enumeration Cases

    case string(String)
    case property(ZarplataEventProperty)
    case oneOf([OneOf])

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let string = try? String(from: decoder) {
            self = .string(string)
        } else if let property = try? ZarplataEventProperty(from: decoder) {
            self = .property(property)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self = .oneOf(try container.decode(forKey: .oneOf))
        }
    }
}

extension ZarplataEventAction {

    // MARK: - Instance Properties

    var description: String? {
        switch self {
        case .property(let property):
            return property.description

        case .string, .oneOf:
            return nil
        }
    }

    var value: String? {
        switch self {
        case .string(let value):
            return value

        case .property, .oneOf:
            return nil
        }
    }

    var oneOf: [OneOf]? {
        switch self {
        case .oneOf(let array):
            return array

        case .property, .string:
            return nil
        }
    }
}
