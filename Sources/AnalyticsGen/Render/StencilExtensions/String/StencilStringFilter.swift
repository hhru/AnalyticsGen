import Foundation

protocol StencilStringFilter: StencilFilter where Input == String, Output == StringFilterOuput {

    // MARK: - Nested Types

    associatedtype StringFilterOuput

    // MARK: - Instance Methods

    func filter(string: String, withArguments: [Any?]) throws -> StringFilterOuput
}

// MARK: -

extension StencilStringFilter {

    // MARK: - Instance Methods

    func filter(input: String, withArguments arguments: [Any?]) throws -> StringFilterOuput {
        try filter(string: input, withArguments: arguments)
    }
}
