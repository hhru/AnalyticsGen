import Foundation
import SwiftCLI

let analyticsGen = CLI(name: "AnalyticsGen", version: .version, description: .description)

analyticsGen.commands = []

analyticsGen.goAndExitOnError()

// MARK: -

private extension String {

    // MARK: - Type Properties

    static let version = "0.1.0"
    static let description = "Generate analytics code for you Swift iOS project"
}
