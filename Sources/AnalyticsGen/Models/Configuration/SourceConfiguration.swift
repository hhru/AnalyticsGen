import Foundation

enum SourceConfiguration: Decodable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case remoteRepo
    }

    case local(path: String)
    case remoteRepo(configuration: RemoteRepoSourceConfiguration)

    var remoteRepoConfiguration: RemoteRepoSourceConfiguration? {
        switch self {
        case .remoteRepo(configuration: let configuration):
            return configuration

        default:
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
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
