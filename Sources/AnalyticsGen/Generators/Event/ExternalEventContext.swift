import Foundation

struct ExternalEventContext: Encodable {

    // MARK: - Nested Types

    struct Label: Encodable {

        // MARK: - Instance Properties

        let description: String?
        let value: String?
        let oneOf: [OneOf]?
    }

    // MARK: -

    struct Action: Encodable {

        // MARK: - Instance Properties

        let description: String?
        let value: String?
        let oneOf: [OneOf]?
    }

    // MARK: -

    struct Category: Encodable {

        let value: String?
        let oneOf: [OneOf]?
    }

    // MARK: -

    struct Parameter: Encodable {

        // MARK: - Instance Properties

        let name: String
        let type: String
    }

    // MARK: - Instance Properties

    let edition: [EventEdition]?
    let deprecated: Bool
    let name: String
    let description: String?
    let category: Category
    let schemeName: String
    let schemePath: String
    let action: Action
    let label: Label?
    let eventProtocol: String
    let initialisationParameters: [Parameter]
}
