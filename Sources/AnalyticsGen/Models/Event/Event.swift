import Foundation

struct Event: Codable {

    // MARK: - Instance Properties

    let application: EventApplication
    let category: String
    let description: String
    let experiment: EventExperiment?
    let external: ExternalEvent?
    let `internal`: InternalEvent?
    let name: String
}
