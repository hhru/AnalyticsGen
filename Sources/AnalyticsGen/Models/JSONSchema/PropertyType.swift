import Foundation

enum PropertyType: Decodable {

    // MARK: - Enumeration Cases

    case single(SimpleType)
    case multiple([SimpleType])

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            let value = try container.decode(SimpleType.self)
            self = .single(value)
        } catch DecodingError.typeMismatch {
            let value = try container.decode([SimpleType].self)
            self = .multiple(value)
        }
    }
}
