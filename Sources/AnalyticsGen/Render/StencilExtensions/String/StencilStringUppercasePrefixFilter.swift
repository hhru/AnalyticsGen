import Foundation

final class StencilStringUppercasePrefixFilter: StencilStringFilter {

    // MARK: - Nested Types

    typealias Input = String
    typealias Output = String
    typealias StringFilterOutput = String

    // MARK: - Instance Properties

    let name = "uppercasePrefix"

    // MARK: - Instance Methods

    func filter(string: String, withArguments arguments: [Any?]) throws -> String {
        arguments
            .compactMap { $0 as? String }
            .reduce(string) { string, prefix in
                guard string.hasPrefix(prefix) else {
                    return string
                }

                let uppercasedPrefix = string.prefix(prefix.count).uppercased()

                return uppercasedPrefix + string.dropFirst(prefix.count)
            }
    }
}
