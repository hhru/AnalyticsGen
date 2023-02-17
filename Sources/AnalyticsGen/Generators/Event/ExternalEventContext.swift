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

    // MARK: - Instance Properties

    let deprecated: Bool
    let name: String
    let description: String?
    let category: Category
    let structName: String
    let action: Action
    let label: Label?
}
