import Foundation

final class StencilStringUppercaseSuffixFilter: StencilStringFilter {

    // MARK: - Nested Types

    typealias Input = String
    typealias Output = String
    typealias StringFilterOutput = String

    // MARK: - Instance Properties

    let name = "uppercaseSuffix"

    // MARK: - Instance Methods

    func filter(string: String, withArguments arguments: [Any?]) throws -> String {
        guard let suffix = arguments.first as? String else {
            return string
        }

        guard string.hasSuffix(suffix) else {
            return string
        }

        let uppercasedSuffix = string.suffix(suffix.count).uppercased()

        return string.dropLast(suffix.count) + uppercasedSuffix
    }
}
