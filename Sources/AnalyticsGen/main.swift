import Foundation
import SwiftCLI
import PathKit

#if DEBUG
Path.current = Path(#file).appending("../../../Example")
#endif

let analyticsGen = CLI(name: "AnalyticsGen", version: .version, description: .description)

analyticsGen.commands = [
    GenerateCommand(generator: Dependencies.eventGenerator)
]

analyticsGen.goAndExitOnError()

// MARK: -

private extension String {

    // MARK: - Type Properties

    static let version = "0.5.8"
    static let description = "Generate analytics code for you Swift iOS project"
}
