import Foundation

struct InternalEventContext: Encodable {

    // MARK: - Nested Types

    struct Experiment: Encodable {

        // MARK: - Instance Properties

        let description: String
        let url: String
    }

    // MARK: -

    struct Parameter: Encodable {

        // MARK: - Instance Properties

        let name: String
        let description: String?
        let oneOf: [OneOf]?
        let const: String?
        let type: String?
    }

    // MARK: - Instance Properties

    let name: String
    let description: String
    let category: String
    let eventName: String
    let experiment: Experiment?
    let structName: String
    let parameters: [Parameter]?
    let hasParametersToInit: Bool
}
