import Foundation

struct ZarplataEvent: Decodable {

    // MARK: - Instance Properties

    let action: ZarplataEventAction
    let category: ZarplataEventCategory
    let forContractor: Bool?
    let label: ZarplataEventLabel?
    let platform: EventPlatform?
}
