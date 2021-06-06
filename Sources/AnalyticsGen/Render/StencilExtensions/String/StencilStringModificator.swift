import Foundation

protocol StencilStringModificator: StencilModificator where Input == String, Output == StringModificatorOuput {

    // MARK: - Nested Types

    associatedtype StringModificatorOuput

    // MARK: - Instance Methods

    func modify(string: String, withArguments: [Any?]) throws -> StringModificatorOuput
}

// MARK: -

extension StencilStringModificator {

    // MARK: - Instance Methods

    func modify(input: String, withArguments arguments: [Any?]) throws -> StringModificatorOuput {
        try modify(string: input, withArguments: arguments)
    }
}
