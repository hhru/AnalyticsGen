import Foundation

enum InternalEventParameterType: Decodable {

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
    case type(PropertyType)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let const = try container.decodeIfPresent(String.self, forKey: .const) {
            self = .const(const)
        } else if let oneOf: [OneOf] = try container.decodeIfPresent(forKey: .oneOf) {
            self = .oneOf(oneOf)
        } else if let propertyType = try? container.decodeIfPresent(PropertyType.self, forKey: .type) {
            self = .type(propertyType)
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

    // MARK: - Instance Properties

    var oneOf: [OneOf]? {
        switch self {
        case .oneOf(let array):
            return array

        case .const, .type:
            return nil
        }
    }

    var const: String? {
        switch self {
        case .const(let value):
            return value

        case .type, .oneOf:
            return nil
        }
    }

    var swiftType: String? {
        switch self {
        case .type(let type):
            switch type {
            case .single(let type):
                return type.swiftType

            case .array(let types):
                guard let swiftType = types.first(where: { $0 != .null })?.swiftType else {
                    return nil
                }

                let optionalSuffix = types.contains(.null) ? "?" : .empty

                return swiftType.appending(optionalSuffix)
            }

        case .const, .oneOf:
            return nil
        }
    }
}
