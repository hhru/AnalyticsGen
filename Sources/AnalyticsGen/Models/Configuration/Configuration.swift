import Foundation

struct Configuration: Decodable {

    // MARK: - Instance Properties

    let source: SourceConfiguration?
    let output: String?
}
