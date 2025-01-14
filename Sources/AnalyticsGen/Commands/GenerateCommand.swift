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
    
    let dependeciesGenerator: DependenciesGenerator
    private(set) var generator: EventGenerator?
    private let fileProvider: FileProvider = YAMLFileProvider()
    
    init(
        dependeciesGenerator: DependenciesGenerator = DefaultDependeciesGenerator()
    ) {
        self.dependeciesGenerator = dependeciesGenerator
    }
    
    // MARK: - AsyncExecutableCommand
    
    func executeAsyncAndExit() throws {
        let configurationPath = self.configurationPath.value ?? .defaultConfigurationPath
        let selectedRemoteRepoProvider = self.provider.value ?? .defaultRemoteRepoProvider
        let configuration = try fileProvider.readFile(at: configurationPath, type: Configuration.self)
        let remoteHost = configuration.remoteHost ?? .defaultRemoteRepoURI
        
        generator = try dependeciesGenerator.createGenerator(for: selectedRemoteRepoProvider, remoteHost: remoteHost)
        
        Log.isDebugLoggingEnabled = debug.value
        
        guard let generator = generator else {
            self.fail(message: "No generator setted up")
        }
        
        firstly {
            generator.generate(configuration: configuration, force: force.value)
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
    static let defaultRemoteRepoURI = "https://forgejo.pyn.ru/api/v1"
}
