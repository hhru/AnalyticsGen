import Foundation
import AnalyticsGenTools

struct Configuration {

    // MARK: - Instance Properties

    let source: SourceConfiguration
    let destination: String?
    let platform: EventPlatform?
    let template: TemplateConfiguration?
    let name: String?
}
