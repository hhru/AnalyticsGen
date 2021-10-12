import Foundation

struct GitReference: Codable, Equatable {

    // MARK: - Nested Types

    enum CodingKeys: String, CodingKey {

        // MARK: - Enumeration Cases

        case ref
        case nodeID = "node_id"
        case url
        case object
    }

    // MARK: -

    struct Object: Codable, Equatable {

        // MARK: - Instance Properties

        let sha: String
        let type: String
        let url: URL
    }

    // MARK: - Instance Properties

    let ref: String
    let nodeID: String
    let url: URL
    let object: Object
}
