import Foundation

final class StencilStringMultilineAlignmentFilter: StencilStringFilter {

    // MARK: - Nested Types

    typealias Input = String
    typealias Output = String
    typealias StringFilterOutput = String

    // MARK: - Instance Properties

    let name = "multilineAlignment"

    // MARK: - Instance Methods

    func filter(string: String, withArguments arguments: [Any?]) throws -> String {
        string.replacingOccurrences(of: "\n", with: "\n    ")
    }
}
