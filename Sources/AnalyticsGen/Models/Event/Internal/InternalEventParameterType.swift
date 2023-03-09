import Foundation

enum InternalEventParameterType: Decodable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case const
        case oneOf
        case type
        case items
    }

    // MARK: - Enumeration Cases

    case const(String)
    case oneOf([OneOf])
    case type(PropertyType)
    case array(SimpleType)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let const = try container.decodeIfPresent(String.self, forKey: .const) {
            self = .const(const)
        } else if let oneOf: [OneOf] = try container.decodeIfPresent(forKey: .oneOf) {
            self = .oneOf(oneOf)
        } else if let propertyType = try? container.decodeIfPresent(PropertyType.self, forKey: .type) {
            self = .type(propertyType)
        } else if let items = try? container.decodeIfPresent(Items.self, forKey: .items) {
            self = .array(items.type)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unexpected internal parameter"
                )
            )
        }
    }
}

// MARK: -

extension InternalEventParameterType {

    // MARK: - Nested Types

    private struct Items: Decodable {

        // MARK: - Instance Properties

        let type: SimpleType
    }
}

// MARK: -

extension InternalEventParameterType {

    // MARK: - Instance Properties

    var oneOf: [OneOf]? {
        switch self {
        case .oneOf(let array):
            return array

        case .const, .type, .array:
            return nil
        }
    }

    var const: String? {
        switch self {
        case .const(let value):
            return value

        case .type, .oneOf, .array:
            return nil
        }
    }

    var swiftType: String? {
        switch self {
        case .type(let type):
            switch type {
            case .single(let type):
                return type.swiftType

            case .multiple(let types):
                guard let swiftType = types.first(where: { $0 != .null })?.swiftType else {
                    return nil
                }

                let optionalSuffix = types.contains(.null) ? "?" : .empty

                return swiftType.appending(optionalSuffix)
            }

        case .array(let type):
            return "[\(type.swiftType)]"

        case .const, .oneOf:
            return nil
        }
    }
}
