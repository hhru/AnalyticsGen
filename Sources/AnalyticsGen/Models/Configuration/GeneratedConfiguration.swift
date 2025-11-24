import Foundation
import AnalyticsGenTools

struct GeneratedConfiguration: Equatable {

    let name: String
    let path: String
    let destination: String?
    let platform: EventPlatform?
    let template: TemplateConfiguration?
}
