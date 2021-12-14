import Foundation

struct ExternalEventContext: Encodable {

    // MARK: - Nested Types

    struct Label: Encodable {

        // MARK: - Instance Properties

        let description: String?
        let oneOf: [OneOf]?
    }

    // MARK: -

    struct Action: Encodable {

        // MARK: - Instance Properties

        let description: String?
        let value: String?
        let oneOf: [OneOf]?
    }

    // MARK: - Instance Properties

    let deprecated: Bool
    let name: String
    let description: String?
    let category: String
    let structName: String
    let action: Action
    let label: Label?
}
