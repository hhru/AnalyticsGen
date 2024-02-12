import Foundation

enum ZarplataEventLabel: Decodable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case oneOf
    }

    // MARK: - Enumeration Cases

    case oneOf([OneOf])
    case property(ZarplataEventProperty)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let array = try container.decodeIfPresent([OneOf].self, forKey: .oneOf) {
            self = .oneOf(array)
        } else {
            self = .property(try ZarplataEventProperty(from: decoder))
        }
    }
}

// MARK: -

extension ZarplataEventLabel {

    // MARK: - Instance Properties

    var description: String? {
        switch self {
        case .property(let property):
            return property.description

        case .oneOf:
            return nil
        }
    }

    var oneOf: [OneOf]? {
        switch self {
        case .oneOf(let array):
            return array

        case .property:
            return nil
        }
    }
}
