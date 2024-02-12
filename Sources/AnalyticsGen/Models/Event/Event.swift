import Foundation

struct Event: Decodable {

    // MARK: - Instance Properties

    let application: EventApplication
    let deprecated: Bool?
    let category: String
    let description: String?
    let experiment: EventExperiment?
    let external: ExternalEvent?
    let `internal`: InternalEvent?
    let zarplata: ZarplataEvent?
    let name: String
}
