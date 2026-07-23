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
