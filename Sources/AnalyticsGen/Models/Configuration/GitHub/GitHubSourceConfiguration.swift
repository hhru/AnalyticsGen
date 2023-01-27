import Foundation

struct GitHubSourceConfiguration: Decodable, Equatable {

    // MARK: - Instance Properties

    let owner: String
    let repo: String
    let path: String?
    let ref: GitHubReferenceConfiguration
    let accessToken: AccessTokenConfiguration
}
