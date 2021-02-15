import Foundation
import SwiftCLI

final class GenerateCommand: AsyncExecutableCommand {

    // MARK: - Instance Properties

    let name = "generate"
    let shortDescription = "Generate analytics events from schemas"

    let configurationPath = Key<String>(
        "--config",
        "-c",
        description: """
            Path to the configuration file.
            Defaults to '\(String.defaultConfigurationPath)'.
            """
    )

    // MARK: - AsyncExecutableCommand

    func executeAsyncAndExit() throws {
        let configurationPath = self.configurationPath.value ?? .defaultConfigurationPath

        succeed(message: "Configuration path: \(configurationPath)")
    }
}

private extension String {

    // MARK: - Type Properties

    static let defaultConfigurationPath = ".analyticsGen.yml"
}
