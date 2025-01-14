import Foundation

struct RemoteRepoSourceConfiguration: Decodable, Equatable {

    // MARK: - Instance Properties

    let owner: String
    let repo: String
    let path: String?
    let ref: RemoteRepoReferenceConfiguration
    let accessToken: AccessTokenConfiguration
}
