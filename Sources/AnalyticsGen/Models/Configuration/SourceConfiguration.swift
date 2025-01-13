import Foundation

enum SourceConfiguration: Decodable, Equatable {

    // MARK: - Nested Types

    private enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case remoteRepo
    }

    // MARK: - Instance Properties

    case local(path: String)
    case remoteRepo(configuration: RemoteRepoSourceConfiguration)

    // MARK: - Initializers

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            //TODO: -
            self = .remoteRepo(configuration: try container.decode(forKey: .remoteRepo))
        } else {
            self = .local(path: try String(from: decoder))
        }
    }
}

extension SourceConfiguration {
    init(source: SourceConfiguration, target: Target) {
        switch source {
        case .local:
            self = source
        case let .remoteRepo(configuration: configuration):
            self = .remoteRepo(
                configuration: RemoteRepoSourceConfiguration(
                    owner: configuration.owner,
                    repo: configuration.repo,
                    path: target.path ?? configuration.path,
                    ref: target.ref ?? configuration.ref,
                    accessToken: configuration.accessToken
                )
            )
        }
    }
}
