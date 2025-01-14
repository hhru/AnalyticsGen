import Foundation
import AnalyticsGenTools

struct Configuration: Decodable, Equatable {
    let source: SourceConfiguration
    let remoteHost: String?
    let destination: String?
    let platform: EventPlatform?
    let template: TemplateConfiguration?
    let targets: [Target]?

    var configurations: [GeneratedConfiguration] {
        if let targets = targets {
            return targets.map { target in
                GeneratedConfiguration(
                    source: SourceConfiguration(source: source, target: target),
                    destination: target.destination ?? destination,
                    platform: target.platform ?? platform,
                    template: template,
                    name: target.name
                )
            }
        } else {
            return [
                GeneratedConfiguration(
                    source: source,
                    destination: destination,
                    platform: platform,
                    template: template,
                    name: "Main"
                )
            ]
        }
    }
}
