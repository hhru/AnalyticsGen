import Foundation
import AnalyticsGenTools

struct GeneratedConfiguration: Equatable {

    // MARK: - Instance Properties

    let source: SourceConfiguration
    let destination: String?
    let platform: EventPlatform?
    let template: TemplateConfiguration?
    let name: String
}
