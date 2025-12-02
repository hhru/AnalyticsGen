import ArgumentParser
import Foundation
import PathKit
import AnalyticsGenTools

@main
struct AnalyticsGen: AsyncParsableCommand {

    struct Generate: AsyncParsableCommand {
        static var configuration = CommandConfiguration(
            abstract: "Generate Swift analytics events code from YAML schemas"
        )

        @Option(name: [.short, .long], help: "Path to the configuration file")
        var config: String = ".analyticsGen.yml"

        @Flag(help: "Enable debug logging")
        var debug: Bool = false

        @Option(name: [.short, .long], help: "Specify branch name for remote repository (overrides default branch)")
        var branch: String?

        func run() async throws {
            #if DEBUG
            if let currentPath = ProcessInfo.processInfo.environment["CURRENT_PATH"] {
                Path.current = Path(currentPath)
            } else {
                Path.current = Path(#file).appending("../../../Example")
            }
            #endif

            let fileProvider = Dependencies.yamlFileProvider
            let generator = Dependencies.eventGenerator

            let configuration = try fileProvider.readFile(at: config, type: Configuration.self)

            Log.isDebugLoggingEnabled = debug

            try await generator.generate(configuration: configuration, branch: branch)

            print("Generation completed successfully!")
        }
    }

    struct Version: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display the current version of AnalyticsGen"
        )

        func run() throws {
            print(String.version)
        }
    }

    static let configuration = CommandConfiguration(
        abstract: "A code generation tool for creating type-safe analytics events from YAML schemas",
        subcommands: [Generate.self, Version.self]
    )
}

private extension String {
    static let version = "0.6.10"
}
