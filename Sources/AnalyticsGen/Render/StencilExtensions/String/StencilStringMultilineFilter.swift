import Foundation

final class StencilStringMultilineFilter: StencilStringFilter {

    // MARK: - Nested Types

    typealias Input = String
    typealias Output = Bool
    typealias StringFilterOutput = Bool

    // MARK: - Instance Properties

    let name = "isMultiline"

    // MARK: - StencilStringFilter

    func filter(string: String, withArguments: [Any?]) throws -> Bool {
        string.contains { $0.isNewline }
    }
}
