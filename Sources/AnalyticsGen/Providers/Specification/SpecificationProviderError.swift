import Foundation

struct SpecificationProviderError: Error {

    // MARK: - Nested Types

    enum Code {
        case invalidSpecification(path: String)
    }

    // MARK: - Instance Properties

    let code: Code
}

// MARK: - CustomStringConvertible

extension SpecificationProviderError: CustomStringConvertible {

    // MARK: - Instance Properties

    var description: String {
        switch code {
        case .invalidSpecification(let path):
            return "Failed to parse specification at path: \(path)"
        }
    }
}
