import Foundation

struct Event: Codable {

    // MARK: - Nested Types

    enum Application: String, Codable {

        // MARK: - Enumeration Cases

        case applicant
        case employer
    }

    // MARK: -

    struct Experiment: Codable {

        // MARK: - Instance Properties

        let description: String
        let name: String?
        let url: String
    }

    // MARK: -

    enum Category: String, Codable {

        // MARK: - Enumeration Cases

        case anonymous
        case anonymousApplicant = "anonymous/applicant"
        case applicant
        case employer
    }

    // MARK: -

    struct OneOf: Codable {

        // MARK: - Instance Properties

        let name: String
        let description: String
    }

    // MARK: -

    struct Label: Codable {

        // MARK: - Instance Properties

        let oneOf: [OneOf]
    }

    // MARK: -

    enum Platform: String, Codable {

        // MARK: - Enumeration Cases

        case android = "Android"
        case androidIOS = "Android/iOS"
        case iOS
    }

    // MARK: -

    struct External: Codable {

        // MARK: - Instance Properties

        let action: String
        let category: Category
        let forContractor: Bool?
        let label: Label?
        let platform: Platform?
    }

    // MARK: -

    struct Internal: Codable {

        // MARK: - Instance Properties

        let event: String
        let platform: Platform?
        let sql: String?
    }

    // MARK: - Instance Properties

    let application: Application
    let category: String
    let description: String
    let experiment: Experiment?
    let external: External?
    let `internal`: Internal?
    let name: String
}
