import Foundation

struct InternalEvent: Decodable {

    // MARK: - Nested Types

    struct CodingKeys: CodingKey, Equatable {

        // MARK: - Type Properties

        static let event = Self(stringValue: "event")!
        static let platform = Self(stringValue: "platform")!
        static let sql = Self(stringValue: "sql")!
        static let parameters = Self(stringValue: "parameters")!
        static let hhtmSource = Self(stringValue: "hhtmSource")!
        static let hhtmFrom = Self(stringValue: "hhtmFrom")!

        // MARK: - Instance Properties

        let stringValue: String
        let intValue: Int?

        // MARK: - Initializers

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            return nil
        }
    }

    // MARK: -

    enum KnownEventName: String {

        // MARK: - Enumeration Cases

        case buttonClick = "button_click"
        case elementShown = "element_shown"
        case screenShown = "screen_shown"
    }

    // MARK: - Instance Properties

    let event: String
    let platform: EventPlatform?
    let sql: String?
    let parameters: [InternalEventParameter]
    let hhtmSource: InternalEventParameter?

    // MARK: -

    var knownEventName: KnownEventName? {
        KnownEventName(rawValue: event)
    }

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let propertyKeys: [CodingKeys] = [.event, .platform, .sql, .hhtmSource, .hhtmFrom]

        self.event = try container.decode(forKey: .event)
        self.platform = try container.decodeIfPresent(forKey: .platform)
        self.sql = try container.decodeIfPresent(forKey: .sql)
        self.hhtmSource = try container.decodeIfPresent(forKey: .hhtmSource)

        self.parameters = try container
            .allKeys
            .lazy
            .filter { !propertyKeys.contains($0) }
            .map { try container.decode(forKey: $0) }
    }
}
