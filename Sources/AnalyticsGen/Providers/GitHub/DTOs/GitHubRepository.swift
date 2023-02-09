import Foundation

struct GitHubRepository: Decodable, Equatable {
    let refs: GitHubRefConnection
}
