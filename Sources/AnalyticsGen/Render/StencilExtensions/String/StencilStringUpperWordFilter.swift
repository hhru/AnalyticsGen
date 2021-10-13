import Foundation

final class StencilStringUpperWordFilter: StencilStringFilter {

    // MARK: - Nested Types

    typealias Input = String
    typealias Output = String
    typealias StringFilterOutput = String

    // MARK: - Instance Properties

    let name = "upperWord"

    // MARK: - Instance Methods

    func filter(string: String, withArguments arguments: [Any?]) throws -> String {
        guard let word = arguments.first as? String else {
            return string
        }

        return string.replacingOccurrences(of: word, with: word.uppercased(), options: .caseInsensitive)
    }
}