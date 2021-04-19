import Foundation
import AnalyticsGenTools

struct TemplateConfiguration: Decodable {

    // MARK: - Nested Types

    struct Template: Decodable {

        // MARK: - Instance Properties

        let path: String
        let options: [String: AnyCodable]?
    }

    // MARK: - Instance Properties

    let `internal`: Template?
    let external: Template?
}
