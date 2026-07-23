import Foundation

struct Event: Decodable {

    let edition: [EventEdition]?
    let deprecated: Bool?
    let category: String
    let description: String?
    let experiment: EventExperiment?
    let external: ExternalEvent?
    let `internal`: InternalEvent?
    let name: String
    let iOSGenerationFlags: [GenerationFlag]?

    var isForDesignSystem: Bool? {
        iOSGenerationFlags?.contains(.isForDesignSystem)
    }
    var isDesignSystem: Bool? {
        iOSGenerationFlags?.contains(.isDesignSystem)
    }
}
