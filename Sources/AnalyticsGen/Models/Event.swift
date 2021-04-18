import Foundation

struct Event: Codable {

    // MARK: - Nested Types

    enum Application: String, Codable {

        // MARK: - Enumeration Cases

        case applicant
        case employer
    }

    // MARK: -

    struct Experiment: Codable {

        // MARK: - Instance Properties

        let description: String
        let name: String?
        let url: String
    }

    // MARK: -

    enum Category: String, Codable {

        // MARK: - Enumeration Cases

        case anonymous
        case anonymousApplicant = "anonymous/applicant"
        case applicant
        case employer
    }

    // MARK: -

    struct OneOf: Codable {

        // MARK: - Instance Properties

        let name: String
        let description: String
    }

    // MARK: -

    struct Label: Codable {

        // MARK: - Instance Properties

        let oneOf: [OneOf]
    }

    // MARK: -

    enum Platform: String, Codable {

        // MARK: - Enumeration Cases

        case android = "Android"
        case androidIOS = "Android/iOS"
        case iOS
    }

    // MARK: -

    struct External: Codable {

        // MARK: - Instance Properties

        let action: String
        let category: Category
        let forContractor: Bool?
        let label: Label?
        let platform: Platform?
    }

    // MARK: -

    enum InternalParameterType: Codable {

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
        case type(String)

        // MARK: - Initializers

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let const = try container.decodeIfPresent(String.self, forKey: .const) {
                self = .const(const)
            } else if let oneOf: [OneOf] = try container.decodeIfPresent(forKey: .oneOf) {
                self = .oneOf(oneOf)
            } else if let type = try container.decodeIfPresent(String.self, forKey: .type) {
                self = .type(type)
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Unexpected internal parameter"
                    )
                )
            }
        }

        // MARK: - Encodable

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .const(let value):
                try container.encode(value, forKey: .const)

            case .oneOf(let variants):
                try container.encode(variants, forKey: .oneOf)

            case .type(let name):
                try container.encode(name, forKey: .type)
            }
        }
    }

    // MARK: -

    struct InternalParameter: Codable {

        // MARK: - Nested Types

        enum CodingKeys: String, CodingKey {

            // MARK: - Enumeration Cases

            case name
            case description
            case type
        }

        // MARK: - Instance Properties

        let name: String
        let description: String
        let type: InternalParameterType

        // MARK: - Initializers

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            guard let name = decoder.codingPath.last?.stringValue else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Failed decode 'name' from CodingPath"
                    )
                )
            }

            self.name = name
            self.description = try container.decode(forKey: .description)
            self.type = try InternalParameterType(from: decoder)
        }
    }

    // MARK: -

    struct Internal: Codable {

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
        let platform: Platform?
        let sql: String?
        let parameters: [InternalParameter]

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

    // MARK: - Instance Properties

    let application: Application
    let category: String
    let description: String
    let experiment: Experiment?
    let external: External?
    let `internal`: Internal?
    let name: String
}
