import Foundation

enum ExternalEventTracker: Decodable {
    case appsFlyer
    case appMetrica

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).lowercased()

        switch rawValue {
        case "appsflyer":
            self = .appsFlyer
        case "appmetrica":
            self = .appMetrica
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unknown tracker value: \(rawValue)"
            )
        }
    }
}
