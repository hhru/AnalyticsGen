import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema
import DictionaryCoder

final class DefaultEventGenerator: EventGenerator {

    // MARK: - Instance Properties

    let fileProvider: FileProvider
    let remoteRepoProvider: RemoteRepoProvider
    let templateRenderer: TemplateRenderer
    let dictionaryDecoder: DictionaryDecoder

    // MARK: - Initializers

    init(
        fileProvider: FileProvider,
        remoteRepoProvider: RemoteRepoProvider,
        templateRenderer: TemplateRenderer,
        dictionaryDecoder: DictionaryDecoder
    ) {
        self.fileProvider = fileProvider
        self.remoteRepoProvider = remoteRepoProvider
        self.templateRenderer = templateRenderer
        self.dictionaryDecoder = dictionaryDecoder
    }

    // MARK: - Instance Methods

    private func fetchGitReference(configuration: GeneratedConfiguration) throws -> Promise<GitReference?> {
        switch configuration.source {
        case .local:
            return .value(.none)

        case .gitHub(let gitHubConfiguration):
            return remoteRepoProvider
                .fetchReference(gitHubConfiguration: gitHubConfiguration)
                .asOptional()
        }
    }

    private func shouldPerformGeneration(
        force: Bool,
        name: String,
        destinationPath: String,
        remoteGitReference: GitReference?
    ) throws -> Bool {
        guard !force else {
            return true
        }

        let hasGeneratedFiles = try? !FileManager
            .default
            .contentsOfDirectory(atPath: destinationPath)
            .filter { $0.lowercased().hasSuffix(.swiftExtension) }
            .isEmpty

        guard (hasGeneratedFiles ?? false),
              let lockReferenceDict: [String: GitReference] = try self.fileProvider.readFileIfExists(
                at: .lockFilePath
              ),
              let remoteGitReference = remoteGitReference,
              let lockReference = lockReferenceDict[name] else {
            return true
        }

        return lockReference != remoteGitReference
    }

    private func resolveSchemasPath(configuration: GeneratedConfiguration, key: String) throws -> Promise<URL> {
        switch configuration.source {
        case .local(let path):
            return .value(URL(fileURLWithPath: path))

        case .gitHub(let gitHubConfiguration):
            return remoteRepoProvider
                .fetchRepo(gitHubConfiguration: gitHubConfiguration, key: key)
                .map { path in
                    gitHubConfiguration.path.map { path.appendingPathComponent($0) } ?? path
                }
        }
    }

    private func clearDestinationFolder(at path: String) throws {
        let fileManager = FileManager.default

        try? fileManager.contentsOfDirectory(atPath: path).forEach { filename in
            if filename.hasSuffix(.swiftExtension) {
                try fileManager.removeItem(atPath: path + "/" + filename)
            }
        }
    }

    private func resolveInternalEventProtocols(event: InternalEvent) -> String {
        let indent = "    "
        var protocols = ["ParametrizedInternalAnalyticsEvent", "SlashAnalyticsEvent"]

        if event.knownEventName == .screenShown {
            protocols.append("ScreenAnalyticsKeyContainable")
        }

        return protocols.joined(separator: ",\n\(indent)")
    }

    private func generate(
        parameters: GenerationParameters,
        event: Event,
        schemaURL: URL,
        platform: EventPlatform
    ) throws {
        let filename = schemaURL.deletingPathExtension().lastPathComponent.deletingSuffix("event").camelized

        if let internalEvent = event.internal, (internalEvent.platform ?? .androidIOS) == platform {
            try templateRenderer.renderTemplate(
                parameters.render.internalTemplate,
                to: parameters.render.destination.appending(path: "\(filename)Event.swift"),
                context: InternalEventContext(
                    deprecated: event.deprecated ?? false,
                    name: event.name,
                    description: event.description,
                    category: event.category,
                    eventName: internalEvent.event,
                    experiment: event.experiment.map {
                        InternalEventContext.Experiment(description: $0.description, url: $0.url.absoluteString)
                    },
                    structName: filename.appending("Event"),
                    protocols: resolveInternalEventProtocols(event: internalEvent),
                    parameters: internalEvent.parameters.nonEmpty?.map { parameter in
                        InternalEventContext.Parameter(
                            name: parameter.name,
                            description: parameter.description,
                            oneOf: parameter.type.oneOf,
                            const: parameter.type.const,
                            type: parameter.type.swiftType
                        )
                    },
                    hasParametersToInit: !internalEvent
                        .parameters
                        .filter { !$0.type.oneOf.isNil || !$0.type.swiftType.isNil }
                        .isEmpty
                )
            )
        }

        if let externalEvent = event.external, (externalEvent.platform ?? .androidIOS) == platform {
            try templateRenderer.renderTemplate(
                parameters.render.externalTemplate,
                to: parameters.render.destination.appending(path: "\(filename)ExternalEvent.swift"),
                context: ExternalEventContext(
                    deprecated: event.deprecated ?? false,
                    name: event.name,
                    description: event.description,
                    category: event.category,
                    structName: filename.appending("ExternalEvent"),
                    action: ExternalEventContext.Action(
                        description: externalEvent.action.description,
                        value: externalEvent.action.value,
                        oneOf: externalEvent.action.oneOf
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

    private func generate(
        configuration: GeneratedConfiguration,
        schemasPath: URL,
        remoteGitReference: GitReference?
    ) throws {
        guard let enumerator = FileManager.default.enumerator(at: schemasPath, includingPropertiesForKeys: nil) else {
            throw MessageError("Failed to create enumerator at \(schemasPath).")
        }

        let generarionParameters = try resolveGenerationParameters(from: configuration)
        let platform = configuration.platform ?? .androidIOS

        let events: [(Event, URL)] = try enumerator
            .lazy
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == .yamlExtension }
            .map { url in
                Log.info("Fetching \(configuration.name) schema: \(url.lastPathComponent)")

                let event: Event = try fileProvider.readFile(at: url.path)

                return (event, url)
            }

        try clearDestinationFolder(at: configuration.destination ?? "./")

        try events.forEach { event, url in
            try generate(parameters: generarionParameters, event: event, schemaURL: url, platform: platform)
        }

        if let reference = remoteGitReference {
            var gitReferences: [String: GitReference] = (try? fileProvider.readFile(at: .lockFilePath)) ?? [:]
            gitReferences[configuration.name] = reference
            try fileProvider.writeFile(content: gitReferences, at: .lockFilePath)
        }
    }

    private func generate(configuration: GeneratedConfiguration, force: Bool) -> Promise<EventGenerationResult> {
        firstly {
            try self.fetchGitReference(configuration: configuration).map { (configuration, $0) }
        }.get { _ in
            Log.info("Checking out analytics events for \(configuration.name)")
        }.then {
            configuration, remoteGitReference -> Promise<EventGenerationResult> in
            guard try self.shouldPerformGeneration(
                force: force,
                name: configuration.name,
                destinationPath: configuration.destination ?? "./",
                remoteGitReference: remoteGitReference
            ) else {
                return .value(.upToDate)
            }
            
            return try self
                .resolveSchemasPath(configuration: configuration, key: configuration.name)
                .done {
                    try self.generate(
                        configuration: configuration,
                        schemasPath: $0,
                        remoteGitReference: remoteGitReference
                    )
                }.get { _ in
                    Log.info("Analytics events for \(configuration.name) are generated")
                }.map { .success }
        }
    }

    // MARK: - EventGenerator

    func generate(configurationPath: String, force: Bool) -> Promise<EventGenerationResult> {
        firstly {
            fileProvider.readFile(at: configurationPath, type: Configuration.self)
        }.map { configuration in
            configuration.configurations.reversed()
        }.get { configurations in
            Log.info("Found \(configurations.count) configurations\n")
        }.then { configurations in
            when(fulfilled: configurations.map { self.generate(configuration: $0, force: force) })
        }.map { results in
            results.contains(.success) ? .success : .upToDate
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
    static let swiftExtension = ".swift"
    static let lockFilePath = ".analyticsGen.lock"
}
