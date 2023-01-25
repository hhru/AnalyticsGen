import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema
import DictionaryCoder
import KeychainAccess

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

    private func generate(configuration: GeneratedConfiguration, schemasPath: URL) throws {
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
                Log.info("(\(configuration.name)) Reading schema: \(url.lastPathComponent)")
                let event: Event = try fileProvider.readFile(at: url.path)
                return (event, url)
            }

        try clearDestinationFolder(at: configuration.destination ?? .rootPath)

        try events.forEach { event, url in
            try generate(parameters: generarionParameters, event: event, schemaURL: url, platform: platform)
        }
    }

    private func shouldGenerate(
        configuration: GeneratedConfiguration,
        remoteGitReference: GitReference
    ) throws -> Bool {
        let hasGeneratedFiles = try? !FileManager
            .default
            .contentsOfDirectory(atPath: configuration.destination ?? .rootPath)
            .filter { $0.lowercased().hasSuffix(.swiftExtension) }
            .isEmpty

        let lockReferenceDict = try fileProvider.readFileIfExists(
            at: .lockFilePath,
            type: [String: GitReference].self
        )

        guard hasGeneratedFiles == true, let lockGitReference = lockReferenceDict?[configuration.name] else {
            return true
        }

        return lockGitReference != remoteGitReference
    }

    private func saveLockfile(configurationName: String, remoteGitReference: GitReference) throws {
        var lockGitRerences = try self.fileProvider.readFileIfExists(
            at: .lockFilePath,
            type: [String: GitReference].self
        ) ?? [:]

        lockGitRerences[configurationName] = remoteGitReference

        try self.fileProvider.writeFile(content: lockGitRerences, at: .lockFilePath)
    }

    private func generateFromRemoteRepo(
        gitHubConfiguration: GitHubSourceConfiguration,
        ref: String,
        configuration: GeneratedConfiguration,
        remoteGitReference: GitReference
    ) -> Promise<EventGenerationResult> {
        firstly {
            remoteRepoProvider.fetchRepo(
                owner: gitHubConfiguration.owner,
                repo: gitHubConfiguration.repo,
                ref: ref,
                token: try gitHubConfiguration.accessToken.resolveToken(),
                key: configuration.name
            )
        }.map { repoPathURL in
            try self.generate(
                configuration: configuration,
                schemasPath: gitHubConfiguration.path.map { repoPathURL.appendingPathComponent($0) } ?? repoPathURL
            )

            try self.saveLockfile(configurationName: configuration.name, remoteGitReference: remoteGitReference)

            return .success
        }
    }

    private func generateFromRemoteRepo(
        gitHubConfiguration: GitHubSourceConfiguration,
        ref: String,
        configuration: GeneratedConfiguration,
        force: Bool
    ) -> Promise<EventGenerationResult> {
        firstly {
            remoteRepoProvider.fetchReference(
                owner: gitHubConfiguration.owner,
                repo: gitHubConfiguration.repo,
                ref: ref,
                token: try gitHubConfiguration.accessToken.resolveToken()
            )
        }.then { remoteGitReference in
            let shouldPerformGeneration = try self.shouldGenerate(
                configuration: configuration,
                remoteGitReference: remoteGitReference
            )

            if shouldPerformGeneration || force {
                return self.generateFromRemoteRepo(
                    gitHubConfiguration: gitHubConfiguration,
                    ref: ref,
                    configuration: configuration,
                    remoteGitReference: remoteGitReference
                )
            } else {
                return .value(.upToDate)
            }
        }
    }

    private func generate(
        configuration: GeneratedConfiguration,
        force: Bool
    ) throws -> Promise<EventGenerationResult> {
        switch configuration.source {
        case .local(let path):
            try generate(configuration: configuration, schemasPath: URL(fileURLWithPath: path))
            return .value(.success)

        case .gitHub(let gitHubConfiguration):
            switch gitHubConfiguration.ref {
            case .tag(let name):
                return generateFromRemoteRepo(
                    gitHubConfiguration: gitHubConfiguration,
                    ref: "tags/\(name)",
                    configuration: configuration,
                    force: force
                )

            case .branch(let name):
                return generateFromRemoteRepo(
                    gitHubConfiguration: gitHubConfiguration,
                    ref: "heads/\(name)",
                    configuration: configuration,
                    force: force
                )

            case .finders(_):
                fatalError()
            }
        }
    }

    // MARK: - EventGenerator

    func generate(configurationPath: String, force: Bool) -> Promise<EventGenerationResult> {
        firstly {
            Promise.value(try fileProvider.readFile(at: configurationPath, type: Configuration.self))
        }.map { configuration in
            configuration.configurations.reversed()
        }.get { configurations in
            Log.info("Found \(configurations.count) configurations\n")
        }.then { configurations in
            when(fulfilled: try configurations.map { try self.generate(configuration: $0, force: force) })
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
    static let rootPath = "./"
}

// MARK: -

private extension AccessTokenConfiguration {

    // MARK: - Instance Methods

    func resolveToken() throws -> String {
        if let value = value {
            return value
        } else if let environmentVariable = environmentVariable,
                  let token = ProcessInfo.processInfo.environment[environmentVariable] {
            return token
        } else if let parameters = keychainParameters {
            let keychain = Keychain(service: parameters.service)

            if let token = try keychain.getString(parameters.key) {
                return token
            }
        }

        throw MessageError("GitHub access token not found.")
    }
}
