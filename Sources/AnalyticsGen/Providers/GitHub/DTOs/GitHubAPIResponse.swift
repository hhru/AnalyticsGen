import Foundation

struct GitHubAPIResponse<Data: Decodable>: Decodable {
    let data: Data
}
