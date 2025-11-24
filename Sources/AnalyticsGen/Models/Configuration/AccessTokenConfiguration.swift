import Foundation
import KeychainAccess
import AnalyticsGenTools

struct AccessTokenConfiguration: Decodable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case environmentVariable = "env"
        case keychain
    }

    struct KeychainParameters: Decodable, Equatable {
        let service: String
        let key: String
    }

    let value: String?
    let environmentVariable: String?
    let keychainParameters: KeychainParameters?

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.value = nil
            self.environmentVariable = try container.decodeIfPresent(forKey: .environmentVariable)
            self.keychainParameters = try container.decodeIfPresent(forKey: .keychain)
        } else {
            self.value = try String(from: decoder)
            self.environmentVariable = nil
            self.keychainParameters = nil
        }
    }

    init(value: String? = nil, environmentVariable: String?, keychainParameters: KeychainParameters?) {
        self.value = value
        self.environmentVariable = environmentVariable
        self.keychainParameters = keychainParameters
    }
}

extension AccessTokenConfiguration {

    func resolveToken() throws -> String {
        if let value = value {
            return value
        } else if let environmentVariable = environmentVariable,
                  let token = ProcessInfo.processInfo.environment[environmentVariable] {
            return token
        } else if let parameters = keychainParameters {
            let keychain = Keychain(service: parameters.service)

            if let token = try keychain.getString(parameters.key) {
                return token
            }
        }

        throw MessageError("Access token not found.")
    }
}
