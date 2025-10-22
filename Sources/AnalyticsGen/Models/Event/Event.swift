import Foundation

struct Event: Decodable {

    // MARK: - Instance Properties

    let application: EventApplication
    let edition: [EventEdition]?
    let deprecated: Bool?
    let category: String
    let description: String?
    let experiment: EventExperiment?
    let external: ExternalEvent?
    let `internal`: InternalEvent?
    let name: String
    let isForDesignSystem: Bool?
    let isDesignSystem: Bool?
}
