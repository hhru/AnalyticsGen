import Foundation

enum ExternalEventCategory: String, Codable {

    // MARK: - Enumeration Cases

    case anonymous
    case anonymousApplicant = "anonymous/applicant"
    case applicant
    case employer
}
