import Foundation
import StencilSwiftKit

class AnalyticsGenStencilSwiftTemplate: StencilSwiftTemplate {

    // MARK: - StencilSwiftTemplate

    override func render(_ dictionary: [String: Any]? = nil) throws -> String {
        try super
            .render(dictionary)
            .replacingOccurrences(of: "(?:\r\n|\r(?!\n)|(?<!\r)\n){2,}", with: "\n\n", options: .regularExpression)
    }
}
