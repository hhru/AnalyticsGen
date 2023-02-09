import Foundation

struct GitHubRefConnection: Decodable, Equatable {
    let edges: [GitHubRefEdge]
}
