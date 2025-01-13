import DictionaryCoder
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
    
    let provider = Key<String>(
        "--provider",
        "-p",
        description: "Enter custom remote repository provider. Default - Forgejo"
    )

    var generator: EventGenerator?
    let dependeciesGenerator: DependenciesGenerator
    
    init(
        dependeciesGenerator: DependenciesGenerator = DefaultDependeciesGenerator()
    ) {
        self.dependeciesGenerator = dependeciesGenerator
    }

    // MARK: - AsyncExecutableCommand

    func executeAsyncAndExit() throws {
        
        let configurationPath = self.configurationPath.value ?? .defaultConfigurationPath
        
        let selectedRemoteRepoProvider = self.provider.value ?? .defaultRemoteRepoProvider
        
        do {
            self.generator = try dependeciesGenerator.createGenerator(for: selectedRemoteRepoProvider)
        } catch {
            self.fail(message: "Failed create generator: \(error)")
        }
        
        Log.isDebugLoggingEnabled = debug.value
        
        guard let generator = generator else {
            self.fail(message: "Failed to setup generator")
        }
        
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
    static let defaultRemoteRepoProvider = "forgejo"
}
