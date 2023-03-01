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
        arguments
            .compactMap { $0 as? String }
            .reduce(string) { string, suffix in
                guard string.hasSuffix(suffix) else {
                    return string
                }

                let uppercasedSuffix = string.suffix(suffix.count).uppercased()

                return string.dropLast(suffix.count) + uppercasedSuffix
            }
    }
}
