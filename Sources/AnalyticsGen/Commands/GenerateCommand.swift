import Foundation
import SwiftCLI
import PromiseKit

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

    let generator: EventGenerator

    // MARK: - Initializers

    init(generator: EventGenerator) {
        self.generator = generator
    }

    // MARK: - AsyncExecutableCommand

    func executeAsyncAndExit() throws {
        let configurationPath = self.configurationPath.value ?? .defaultConfigurationPath

        firstly {
            generator.generate(configurationPath: configurationPath)
        }.done {
            self.succeed(message: "Generation completed successfully!")
        }.catch { error in
            self.fail(message: "Failed to generate with error: \(error)")
        }
    }
}

private extension String {

    // MARK: - Type Properties

    static let defaultConfigurationPath = ".analyticsGen.yml"
}
