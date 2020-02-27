import Foundation
import SwiftCLI

// MARK: - Constants

private enum Constants {

    // MARK: - Type Properties

    static let version = "0.1.0"
    static let description = "Generate analytics code for you Swift iOS project"
}

let analyticsGen = CLI(name: "AnalyticsGen", version: Constants.version, description: Constants.description)

analyticsGen.commands = [
    TrackersCommand(generator: Dependencies.trackersGenerator)
]

analyticsGen.goAndExitOnError()
