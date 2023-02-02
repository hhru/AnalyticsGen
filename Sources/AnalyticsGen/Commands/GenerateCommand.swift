import Foundation
import SwiftCLI
import PromiseKit
import AnalyticsGenTools

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

    let force = Flag(
        "--force",
        description: """
            Regenerate all analytics events ignoring last commit in lock file.
            By default, generation will perform only if has new commits.
            """
    )

    let debug = Flag(
        "--debug",
        description: "Enable debug logging."
    )

    let generator: EventGenerator

    // MARK: - Initializers

    init(generator: EventGenerator) {
        self.generator = generator
    }

    // MARK: - AsyncExecutableCommand

    func executeAsyncAndExit() throws {
        let configurationPath = self.configurationPath.value ?? .defaultConfigurationPath

        Log.isDebugLoggingEnabled = debug.value

        firstly {
            generator.generate(configurationPath: configurationPath, force: force.value)
        }.done { result in
            switch result {
            case .success:
                self.succeed(message: "Generation completed successfully!")

            case .upToDate:
                self.succeed(message: "Analytic events is up to date!")
            }
        }.catch { error in
            self.fail(message: "Failed to generate with error: \(error)")
        }
    }
}

private extension String {

    // MARK: - Type Properties

    static let defaultConfigurationPath = ".analyticsGen.yml"
}
