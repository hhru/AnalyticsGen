import Foundation
import AnalyticsGenTools

struct Configuration: Decodable, Equatable {

    let source: SourceConfiguration
    let platform: EventPlatform?
    let template: TemplateConfiguration?
    let targets: [Target]

    var generatedConfigurations: [GeneratedConfiguration] {
        targets.map { target in
            GeneratedConfiguration(
                name: target.name,
                path: target.path,
                destination: target.destination,
                platform: platform,
                template: template
            )
        }
    }
}
