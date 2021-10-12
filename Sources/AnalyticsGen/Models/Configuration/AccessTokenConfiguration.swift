import Foundation

enum AccessTokenConfiguration: Decodable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {
        case environmentVariable = "env"
        case keychain
    }

    // MARK: -

    struct KeychainParameters: Decodable {

        // MARK: - Instance Properties

        let service: String
        let key: String
    }

    // MARK: - Enumeration Cases

    case environmentVariable(String)
    case keychain(KeychainParameters)
    case value(String)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            if let value = try container.decodeIfPresent(String.self, forKey: .environmentVariable) {
                self = .environmentVariable(value)
            } else {
                self = .keychain(try container.decode(forKey: .keychain))
            }
        } else {
            self = .value(try String(from: decoder))
        }
    }
}
