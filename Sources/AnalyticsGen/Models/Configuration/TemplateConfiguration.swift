import Foundation
import AnalyticsGenTools

struct TemplateConfiguration: Decodable, Equatable {

    struct Template: Decodable, Equatable {
        let path: String?
        let options: [String: AnyCodable]?
    }

    let `internal`: Template?
    let external: Template?
    let externalInternal: Template?
}
