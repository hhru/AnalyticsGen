import Foundation

struct InternalEvent: Codable {

    // MARK: - Nested Types

    struct CodingKeys: CodingKey, Equatable {

        // MARK: - Type Properties

        static let event = CodingKeys(stringValue: "event")!
        static let platform = CodingKeys(stringValue: "platform")!
        static let sql = CodingKeys(stringValue: "sql")!
        static let parameters = CodingKeys(stringValue: "parameters")!

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

    // MARK: - Instance Properties

    let event: String
    let platform: EventPlatform?
    let sql: String?
    let parameters: [InternalEventParameter]

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let propertyKeys: [CodingKeys] = [.event, .platform, .sql]

        self.event = try container.decode(forKey: .event)
        self.platform = try container.decodeIfPresent(forKey: .platform)
        self.sql = try container.decodeIfPresent(forKey: .sql)

        self.parameters = try container
            .allKeys
            .lazy
            .filter { !propertyKeys.contains($0) }
            .map { try container.decode(forKey: $0) }
    }

    // MARK: - Encodable

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(event, forKey: .event)
        try container.encodeIfPresent(platform, forKey: .platform)
        try container.encodeIfPresent(sql, forKey: .sql)
        try container.encode(parameters, forKey: .parameters)
    }
}
