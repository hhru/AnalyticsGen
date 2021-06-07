import Foundation

struct GitHubSourceConfiguration: Decodable {

    // MARK: - Instance Properties

    let owner: String
    let repo: String
    let path: String?
}
