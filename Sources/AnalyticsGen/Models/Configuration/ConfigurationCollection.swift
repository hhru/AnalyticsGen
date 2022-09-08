import Foundation
import AnalyticsGenTools

struct ConfigurationCollection: Decodable {
    let source: SourceConfiguration
    let destination: String?
    let platform: EventPlatform?
    let template: TemplateConfiguration?
    let name: String?
    let targets: [Target]?

    var configurations: [Configuration] {
        if let targets = targets {
            return targets.map { target in
                Configuration(
                    source: SourceConfiguration(source: source, target: target),
                    destination: target.destination ?? destination,
                    platform: target.platform ?? platform,
                    template: template,
                    name: target.name
                )
            }
        } else {
            return [
                Configuration(
                    source: source,
                    destination: destination,
                    platform: platform,
                    template: template,
                    name: nil
                )
            ]
        }
    }
}
