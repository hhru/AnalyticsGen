import Foundation
import AnalyticsGenTools

struct Configuration: Decodable {

    // MARK: - Instance Properties

    let source: SourceConfiguration
    let destination: String?
    let platform: EventPlatform?
    let template: TemplateConfiguration?
}
