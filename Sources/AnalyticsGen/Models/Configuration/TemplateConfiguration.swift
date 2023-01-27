import Foundation
import AnalyticsGenTools

struct TemplateConfiguration: Decodable, Equatable {

    // MARK: - Nested Types

    struct Template: Decodable, Equatable {

        // MARK: - Instance Properties

        let path: String?
        let options: [String: AnyCodable]?
    }

    // MARK: - Instance Properties

    let `internal`: Template?
    let external: Template?
    let externalInternal: Template?
}
