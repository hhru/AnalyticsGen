import Foundation
import AnalyticsGenTools

protocol StencilFilter: StencilExtension {

    // MARK: - Nested Types

    associatedtype Input
    associatedtype Output

    // MARK: - Instance Methods

    func filter(input: Input, withArguments arguments: [Any?]) throws -> Output
}

// MARK: -

extension StencilFilter {

    // MARK: - Instance Methods

    func register(in extensionRegistry: ExtensionRegistry) {
        extensionRegistry.registerFilter(name) { value, parameters in
            guard let input = value as? Input else {
                throw StencilFilterError(code: .invalidValue(value), filter: name)
            }

            return try self.filter(input: input, withArguments: parameters)
        }
    }
}
