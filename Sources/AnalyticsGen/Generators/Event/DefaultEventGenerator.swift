import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema
import DictionaryCoder

final class DefaultEventGenerator: EventGenerator {

    // MARK: - Instance Properties

    let configurationProvider: ConfigurationProvider
    let eventProvider: EventProvider
    let remoteRepoProvider: RemoteRepoProvider
    let templateRenderer: TemplateRenderer
    let dictionaryDecoder: DictionaryDecoder

    // MARK: - Initializers

    init(
        configurationProvider: ConfigurationProvider,
        eventProvider: EventProvider,
        remoteRepoProvider: RemoteRepoProvider,
        templateRenderer: TemplateRenderer,
        dictionaryDecoder: DictionaryDecoder
    ) {
        self.configurationProvider = configurationProvider
        self.eventProvider = eventProvider
        self.remoteRepoProvider = remoteRepoProvider
        self.templateRenderer = templateRenderer
        self.dictionaryDecoder = dictionaryDecoder
    }

    private func resolveSchemasPath(configuration: Configuration) throws -> Promise<URL> {
        switch configuration.source {
        case .local(let path):
            return .value(URL(fileURLWithPath: path))

        case .gitHub(let gitHubConfiguration):
            return remoteRepoProvider
                .fetchRepo(
                    owner: gitHubConfiguration.owner,
                    repo: gitHubConfiguration.repo,
                    branch: gitHubConfiguration.branch,
                    username: gitHubConfiguration.username,
                    token: try gitHubConfiguration.accessToken.resolveToken()
                )
                .map { path in
                    gitHubConfiguration.path.map { path.appendingPathComponent($0) } ?? path
                }
        }
    }

    private func generate(parameters: GenerationParameters, event: Event, schemaURL: URL) throws {
        let filename = schemaURL.deletingPathExtension().lastPathComponent.camelized.appending(String.filenameSuffix)
        let context = EventContext(event: event, filename: filename)

        if event.internal != nil, event.external == nil {
            try templateRenderer.renderTemplate(
                parameters.render.internalTemplate,
                to: parameters.render.destination.appending(path: "\(filename).swift"),
                context: context
            )
        } else if event.external != nil, event.internal == nil {
            try templateRenderer.renderTemplate(
                parameters.render.externalTemplate,
                to: parameters.render.destination.appending(path: "\(filename).swift"),
                context: context
            )
        } else {
            try templateRenderer.renderTemplate(
                parameters.render.externalInternalTemplate,
                to: parameters.render.destination.appending(path: "\(filename).swift"),
                context: context
            )
        }
    }

    private func generate(configuration: Configuration, schemasPath: URL) throws {
        guard let enumerator = FileManager.default.enumerator(at: schemasPath, includingPropertiesForKeys: nil) else {
            throw MessageError("Failed to create enumerator at \(schemasPath).")
        }

        let generarionParameters = try resolveGenerationParameters(from: configuration)

        for case let schemaURL as URL in enumerator where schemaURL.pathExtension == .yamlExtension {
            let event = try eventProvider.fetchEvent(from: schemaURL)

            try generate(parameters: generarionParameters, event: event, schemaURL: schemaURL)
        }
    }

    // MARK: - EventGenerator

    func generate(configurationPath: String) -> Promise<Void> {
        firstly {
            configurationProvider.fetchConfiguration(from: configurationPath)
        }.then { configuration in
            try self.resolveSchemasPath(configuration: configuration).map { (configuration, $0) }
        }.done { configuration, schemasPath in
            try self.generate(configuration: configuration, schemasPath: schemasPath)
        }
    }
}

// MARK: - GenerationParametersResolving

extension DefaultEventGenerator: GenerationParametersResolving {

    // MARK: - Instance Properties

    var defaultInternalTemplateType: RenderTemplateType {
        .native(name: "InternalEvent")
    }

    var defaultExternalTemplateType: RenderTemplateType {
        .native(name: "ExternalEvent")
    }

    var defaultExternalInternalTemplateType: RenderTemplateType {
        .native(name: "ExternalInternalEvent")
    }

    var defaultDestination: RenderDestination {
        .console
    }
}

// MARK: -

private extension RenderDestination {

    // MARK: - Instance Methods

    func appending(path: String) -> Self {
        switch self {
        case .file(let filePath):
            return .file(path: filePath.appending("/\(path)"))

        case .console:
            return self
        }
    }
}

// MARK: -

private extension String {

    // MARK: - Type Properties

    static let filenameSuffix = "Event"
    static let yamlExtension = "yaml"
}

// MARK: -

private extension AccessTokenConfiguration {

    // MARK: - Instance Methods

    func resolveToken() throws -> String {
        switch self {
        case .value(let token):
            return token

        case .environmentVariable(let environmentVariable):
            guard let token = ProcessInfo.processInfo.environment[environmentVariable] else {
                throw MessageError("Environment variable '\(environmentVariable)' not found.")
            }

            return token
        }
    }
}
