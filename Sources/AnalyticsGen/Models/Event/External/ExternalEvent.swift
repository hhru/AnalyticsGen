import Foundation

struct ExternalEvent: Decodable {

    // MARK: - Instance Properties

    let action: ExternalEventAction
    let category: ExternalEventCategory
    let forContractor: Bool?
    let label: ExternalEventLabel?
    let platform: EventPlatform?
}
