import Foundation

struct Configuration: Decodable {

    // MARK: - Instance Properties

    let specification: String
    let source: SourceConfiguration?
    let output: String?
}
