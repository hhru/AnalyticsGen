import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema
import DictionaryCoder
import KeychainAccess

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
                    ref: gitHubConfiguration.ref,
                    username: gitHubConfiguration.username,
                    token: try gitHubConfiguration.accessToken.resolveToken()
                )
                .map { path in
                    gitHubConfiguration.path.map { path.appendingPathComponent($0) } ?? path
                }
        }
    }

    private func generate(parameters: GenerationParameters, event: Event, schemaURL: URL) throws {
        let filename = schemaURL.deletingPathExtension().lastPathComponent.camelized
        let screenShownDefaultParameters: [InternalEventParameter.KnownName?] = [.screenName, .hhtmSource, .hhtmFrom]

        if let internalEvent = event.internal {
            if internalEvent.knownEventName == .screenShown,
               internalEvent.parameters.filter({ !screenShownDefaultParameters.contains($0.knownName) }).isEmpty {
                return
            }

            try templateRenderer.renderTemplate(
                parameters.render.internalTemplate,
                to: parameters.render.destination.appending(path: "\(filename)Event.swift"),
                context: InternalEventContext(
                    name: event.name,
                    description: event.description,
                    category: event.category,
                    eventName: internalEvent.event,
                    experiment: event.experiment.map {
                        InternalEventContext.Experiment(description: $0.description, url: $0.url.absoluteString)
                    },
                    structName: filename.appending("Event"),
                    parameters: internalEvent.parameters.nonEmpty?.map { parameter in
                        InternalEventContext.Parameter(
                            name: parameter.name,
                            description: parameter.description,
                            oneOf: parameter.type.oneOf,
                            const: parameter.type.const,
                            type: parameter.type.swiftType
                        )
                    }
                )
            )
        }

        if let externalEvent = event.external {
            try templateRenderer.renderTemplate(
                parameters.render.externalTemplate,
                to: parameters.render.destination.appending(path: "\(filename)ExternalEvent.swift"),
                context: ExternalEventContext(
                    name: event.name,
                    description: event.description,
                    category: event.category,
                    structName: filename.appending("ExternalEvent"),
                    action: ExternalEventContext.Action(
                        description: externalEvent.action.description,
                        value: externalEvent.action.value
                    ),
                    label: externalEvent.label.map { label in
                        ExternalEventContext.Label(
                            description: label.description,
                            oneOf: label.oneOf
                        )
                    }
                )
            )
        }
    }

    private func generate(configuration: Configuration, schemasPath: URL) throws {
        guard let enumerator = FileManager.default.enumerator(at: schemasPath, includingPropertiesForKeys: nil) else {
            throw MessageError("Failed to create enumerator at \(schemasPath).")
        }

        let generarionParameters = try resolveGenerationParameters(from: configuration)

        for case let schemaURL as URL in enumerator where schemaURL.pathExtension == .yamlExtension {
            Log.info("Fetching schema: \(schemaURL)")

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

        case .keychain(let parameters):
            let keychain = Keychain(service: parameters.service)

            guard let token = try keychain.getString(parameters.key) else {
                throw MessageError("Failed to obtain token from keychain")
            }

            return token
        }
    }
}
