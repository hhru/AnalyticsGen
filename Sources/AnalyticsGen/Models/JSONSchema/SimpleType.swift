import Foundation

enum SimpleType: String, Decodable {

    // MARK: - Enumeration Cases

    case boolean
    case integer
    case null
    case number
    case object
    case string
    case double
    case float
}

// MARK: -

extension SimpleType {

    // MARK: - Instance Properties

    var swiftType: String {
        switch self {
        case .boolean:
            return "Bool"

        case .integer:
            return "Int"

        case .null:
            return "Optional<Any>.none"

        case .number, .double:
            return "Double"

        case .object:
            return "Any"

        case .string:
            return "String"

        case .float:
            return "Float"
        }
    }
}
