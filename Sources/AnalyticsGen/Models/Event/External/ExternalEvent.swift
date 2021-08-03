import Foundation

struct ExternalEvent: Codable {

    // MARK: - Instance Properties

    let action: String
    let category: ExternalEventCategory
    let forContractor: Bool?
    let label: ExternalEventLabel?
    let platform: EventPlatform?
}
