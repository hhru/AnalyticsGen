import Foundation
import AnalyticsGenTools

struct Configuration: Decodable {

    // MARK: - Instance Properties

    let specification: String
    let source: SourceConfiguration?
    let destination: String?
    let template: TemplateConfiguration?
}
