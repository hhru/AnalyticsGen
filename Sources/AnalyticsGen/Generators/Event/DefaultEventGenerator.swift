import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema
import DictionaryCoder

final class DefaultEventGenerator: EventGenerator {

    // MARK: - Instance Properties

    private let fileProvider: FileProvider
    private let remoteRepoProvider: RemoteRepoProvider
    private let templateRenderer: TemplateRenderer
    private let dictionaryDecoder: DictionaryDecoder
    private let remoteRepoReferenceFinder: RemoteRepoReferenceFinder

    // MARK: -

    private var currentVersion: String {
        analyticsGen.version ?? "0.0.0"
    }

    // MARK: - Initializers

    init(
        fileProvider: FileProvider,
        remoteRepoProvider: RemoteRepoProvider,
        templateRenderer: TemplateRenderer,
        dictionaryDecoder: DictionaryDecoder,
        remoteRepoReferenceFinder: RemoteRepoReferenceFinder
    ) {
        self.fileProvider = fileProvider
        self.remoteRepoProvider = remoteRepoProvider
        self.templateRenderer = templateRenderer
        self.dictionaryDecoder = dictionaryDecoder
        self.remoteRepoReferenceFinder = remoteRepoReferenceFinder
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

    private func resolveExternalEventCategory(event: ExternalEvent) -> ExternalEventContext.Category {
        switch event.category {
        case .anonymous, .applicant, .employer, .hhMobileUUID:
            return .init(value: event.category.rawValue, oneOf: nil)
        case .anonymousApplicant:
            return .init(
                value: nil,
                oneOf: [
                    OneOf(name: ExternalEventCategory.applicant.rawValue, description: nil),
                    OneOf(name: ExternalEventCategory.anonymous.rawValue, description: nil)
                ]
            )
        }
    }

    private func resolveExternalEventInitialisationParameters(event: ExternalEvent) -> [ExternalEventContext.Parameter] {
        var parameters: [ExternalEventContext.Parameter] = []
        if resolveExternalEventCategory(event: event).oneOf != nil {
            parameters.append(ExternalEventContext.Parameter(name: "oneOfCategory", type: "Category"))
        }
        if event.action.oneOf != nil {
            parameters.append(ExternalEventContext.Parameter(name: "oneOfAction", type: "Action"))
        } else if event.action.value == nil {
            parameters.append(ExternalEventContext.Parameter(name: "action", type: "String"))
        }
        if let labelOneOf = event.label?.oneOf, labelOneOf.count > 1 {
            parameters.append(ExternalEventContext.Parameter(name: "oneOfLabel", type: "Label"))
        } else if let label = event.label, label.oneOf == nil {
            parameters.append(ExternalEventContext.Parameter(name: "label", type: "String"))
        }
        return parameters
    }

    private func generate(
        parameters: GenerationParameters,
        event: Event,
        schemaURL: URL,
        platform: EventPlatform
    ) throws {
        let fileName = schemaURL.deletingPathExtension().lastPathComponent.deletingSuffix("event").camelized

        if let internalEvent = event.internal, (internalEvent.platform ?? .iOSAndroid) == platform {
            try templateRenderer.renderTemplate(
                parameters.render.internalTemplate,
                to: parameters.render.destination.appending(path: "\(fileName)Event.swift"),
                context: InternalEventContext(
                    edition: event.edition,
                    deprecated: event.deprecated ?? false,
                    name: event.name,
                    description: event.description,
                    category: event.category,
                    experiment: event.experiment.map {
                        InternalEventContext.Experiment(description: $0.description, url: $0.url.absoluteString)
                    },
                    eventName: internalEvent.event,
                    fileName: fileName,
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

        if let externalEvent = event.external, (externalEvent.platform ?? .iOSAndroid) == platform {
            try templateRenderer.renderTemplate(
                parameters.render.externalTemplate,
                to: parameters.render.destination.appending(path: "\(fileName)ExternalEvent.swift"),
                context: ExternalEventContext(
                    edition: event.edition,
                    deprecated: event.deprecated ?? false,
                    name: event.name,
                    description: event.description,
                    category: resolveExternalEventCategory(event: externalEvent),
                    structName: fileName.appending("ExternalEvent"),
                    action: ExternalEventContext.Action(
                        description: externalEvent.action.description,
                        value: externalEvent.action.value,
                        oneOf: externalEvent.action.oneOf
                    ),
                    label: externalEvent.label.map { label in
                        if let first = label.oneOf?.first, label.oneOf?.count == 1 {
                            return ExternalEventContext.Label(
                                description: label.description,
                                value: first.name,
                                oneOf: nil
                            )
                        }
                        return ExternalEventContext.Label(
                            description: label.description,
                            value: nil,
                            oneOf: label.oneOf
                        )
                    },
                    initialisationParameters: resolveExternalEventInitialisationParameters(event: externalEvent)
                )
            )
        }
    }

    private func generate(configuration: GeneratedConfiguration, schemasPath: URL) throws {
        guard let enumerator = FileManager.default.enumerator(at: schemasPath, includingPropertiesForKeys: nil) else {
            throw MessageError("Failed to create enumerator at \(schemasPath).")
        }

        Log.info("(\(configuration.name)) Starting code generation... 🚀")

        let generarionParameters = try resolveGenerationParameters(from: configuration)
        let platform = configuration.platform ?? .iOSAndroid

        let events: [(Event, URL)] = try enumerator
            .lazy
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == .yamlExtension }
            .map { url in
                Log.debug("(\(configuration.name)) Reading schema: \(url.lastPathComponent)")
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
        remoteReferenceSHA: String
    ) throws -> Bool {
        let hasGeneratedFiles = try? !FileManager
            .default
            .contentsOfDirectory(atPath: configuration.destination ?? .rootPath)
            .filter { $0.lowercased().hasSuffix(.swiftExtension) }
            .isEmpty

        let lockReferenceDict = try? fileProvider.readFileIfExists(
            at: .lockFilePath,
            type: [String: LockReference].self
        )

        guard hasGeneratedFiles == true, let lockReference = lockReferenceDict?[configuration.name] else {
            return true
        }

        let remoteLockReference = LockReference(
            sha: remoteReferenceSHA,
            version: currentVersion
        )

        return lockReference != remoteLockReference
    }

    private func saveLockfile(configurationName: String, remoteReferenceSHA: String) throws {
        var lockGitRerences = (
            try? fileProvider.readFileIfExists(
                at: .lockFilePath,
                type: [String: LockReference].self
            )
        ) ?? [:]

        lockGitRerences[configurationName] = LockReference(
            sha: remoteReferenceSHA,
            version: currentVersion
        )

        try fileProvider.writeFile(content: lockGitRerences, at: .lockFilePath)
    }

    private func generateFromRemoteRepo(
        gitHubConfiguration: GitHubSourceConfiguration,
        ref: String,
        configuration: GeneratedConfiguration,
        remoteReferenceSHA: String
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

            try self.saveLockfile(configurationName: configuration.name, remoteReferenceSHA: remoteReferenceSHA)

            return .success
        }
    }

    private func fetchRemoteReferenceSHA(
        gitHubConfiguration: GitHubSourceConfiguration,
        gitReferenceType: GitReferenceType
    ) -> Promise<String> {
        switch gitReferenceType {
        case .tag, .branch:
            return firstly {
                remoteRepoProvider.fetchReference(
                    owner: gitHubConfiguration.owner,
                    repo: gitHubConfiguration.repo,
                    ref: gitReferenceType.rawValue,
                    token: try gitHubConfiguration.accessToken.resolveToken()
                )
            }.map { reference in
                reference.object.sha
            }

        case .commit(let sha):
            return .value(sha)
        }
    }

    private func generateFromRemoteRepo(
        gitHubConfiguration: GitHubSourceConfiguration,
        gitReferenceType: GitReferenceType,
        configuration: GeneratedConfiguration,
        force: Bool
    ) -> Promise<EventGenerationResult> {
        firstly {
            fetchRemoteReferenceSHA(gitHubConfiguration: gitHubConfiguration, gitReferenceType: gitReferenceType)
        }.then { remoteReferenceSHA in
            let shouldPerformGeneration = try self.shouldGenerate(
                configuration: configuration,
                remoteReferenceSHA: remoteReferenceSHA
            )

            if shouldPerformGeneration || force {
                return self.generateFromRemoteRepo(
                    gitHubConfiguration: gitHubConfiguration,
                    ref: gitReferenceType.rawValue,
                    configuration: configuration,
                    remoteReferenceSHA: remoteReferenceSHA
                )
            } else {
                return .value(.upToDate)
            }
        }
    }

    private func performFinders(
        finderConfigurations: [GitHubReferenceFinderConfiguration],
        gitHubConfiguration: GitHubSourceConfiguration,
        generatedConfiguration: GeneratedConfiguration,
        force: Bool
    ) throws -> Promise<EventGenerationResult> {
        Log.info(
            String(
                format: "(%@) Searching remote repo reference via %d finder(s)...",
                generatedConfiguration.name,
                finderConfigurations.count
            )
        )

        return try remoteRepoReferenceFinder
            .findReference(
                configurations: finderConfigurations,
                gitHubConfiguration: gitHubConfiguration
            )
            .map { gitReferenceType in
                if let gitReferenceType {
                    return gitReferenceType
                } else {
                    throw MessageError("Remote repo reference not found.")
                }
            }
            .get { (gitReferenceType: GitReferenceType) in
                Log.info(
                    String(
                        format: "(%@) Found remote repo reference '%@'.",
                        generatedConfiguration.name,
                        gitReferenceType.rawValue
                    )
                )
            }
            .then { gitReferenceType in
                self.generateFromRemoteRepo(
                    gitHubConfiguration: gitHubConfiguration,
                    gitReferenceType: gitReferenceType,
                    configuration: generatedConfiguration,
                    force: force
                )
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
                    gitReferenceType: .tag(name: name),
                    configuration: configuration,
                    force: force
                )

            case .branch(let name):
                return generateFromRemoteRepo(
                    gitHubConfiguration: gitHubConfiguration,
                    gitReferenceType: .branch(name: name),
                    configuration: configuration,
                    force: force
                )

            case .finders(let finders):
                return try performFinders(
                    finderConfigurations: finders,
                    gitHubConfiguration: gitHubConfiguration,
                    generatedConfiguration: configuration,
                    force: force
                )
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
        }.then(on: .global()) { configurations in
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
