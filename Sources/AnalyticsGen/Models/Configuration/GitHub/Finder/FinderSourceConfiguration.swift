import Foundation

struct FinderSourceConfiguration: Decodable, Equatable {
    enum SourceType: Equatable {
        struct File: Decodable, Equatable {
            let path: String
            let variable: String
        }

        case environment(variables: [String])
        case file(files: [File])
        case git
    }

    let type: SourceType
    let condition: FinderConditionConfiguration

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let environment = try? container.decode(EnvironmentVariables.self, forKey: .type) {
            self.type = .environment(variables: environment.env)
        } else if let files = try? container.decode(Files.self, forKey: .type) {
            self.type = .file(files: files.file)
        } else if let rawType = try? container.decode(String.self, forKey: .type), rawType == "git" {
            self.type = .git
        } else {
            throw DecodingError.typeMismatch(
                SourceType.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid source type, expected 'env' 'file' or 'git'",
                    underlyingError: nil
                )
            )
        }

        self.condition = try container.decode(forKey: .condition)
    }

    init(type: SourceType, condition: FinderConditionConfiguration) {
        self.type = type
        self.condition = condition
    }
}

extension FinderSourceConfiguration {

    private struct EnvironmentVariables: Decodable {
        let env: [String]
    }

    private struct Files: Decodable {
        let file: [SourceType.File]
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case env
        case file
        case git
        case condition
    }
}
