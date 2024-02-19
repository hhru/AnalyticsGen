import Foundation

enum ExternalEventCategory: String, Decodable {

    // MARK: - Enumeration Cases

    case anonymous
    case anonymousApplicant = "anonymous/applicant"
    case applicant
    case employer
    case hhMobileUUID = "hhmobile_uuid"
}
