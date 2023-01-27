import Foundation

enum FinderConditionConfiguration: Decodable, Equatable {
    case regex(String)
    case const(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try container.decode(RawType.self, forKey: .type)
        let value = try container.decode(String.self, forKey: .value)

        switch rawType {
        case .regex:
            self = .regex(value)

        case .const:
            self = .const(value)
        }
    }
}

extension FinderConditionConfiguration {

    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    private enum RawType: String, Decodable {
        case regex
        case const
    }
}
