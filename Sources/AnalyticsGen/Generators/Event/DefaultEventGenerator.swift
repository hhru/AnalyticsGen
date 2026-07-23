import AnalyticsGenTools
import DictionaryCoder
import Foundation
import JSONSchema
import PathKit
import Yams

final class DefaultEventGenerator {

    private let fileProvider: FileProvider
    private let remoteRepoProvider: RemoteRepoProvider
    private let templateRenderer: TemplateRenderer
    private let dictionaryDecoder: DictionaryDecoder
    private let branchSynchronizer: AnalyticsBranchSynchronizer

    init(
        fileProvider: FileProvider,
        remoteRepoProvider: RemoteRepoProvider,
        templateRenderer: TemplateRenderer,
        dictionaryDecoder: DictionaryDecoder,
        branchSynchronizer: AnalyticsBranchSynchronizer
    ) {
        self.fileProvider = fileProvider
        self.remoteRepoProvider = remoteRepoProvider
        self.templateRenderer = templateRenderer
        self.dictionaryDecoder = dictionaryDecoder
        self.branchSynchronizer = branchSynchronizer
    }

    private func clearDestinationFolder(at path: String) throws {
        let fileManager = FileManager.default

        try? fileManager.contentsOfDirectory(atPath: path).forEach { filename in
            try fileManager.removeItem(atPath: path + "/" + filename)
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

    private func resolveEventProtocol(event: ExternalEvent) -> String {
        let protocolName: String
        switch event.tracker {
        case .appsFlyer:
            protocolName = "AppsFlyerEvent"
        case .appMetrica:
            protocolName = "AppMetricaEvent"
        case .none:
            protocolName = "AllExternalAnalyticsEvent"
        }

        return protocolName
    }

    private func generate(
        parameters: GenerationParameters,
        event: Event,
        targetPath: String,
        schemePath: [String],
        platform: EventPlatform
    ) throws {
        let filePath = schemePath
            .dropLast()
            .map { $0.camelized }
            .joined(separator: "/")
        if filePath.contains("DesignSystem/Templates") {
            return
        }

        let schemeName = schemePath
            .last?
            .components(separatedBy: ".")
            .first?
            .deletingSuffix("event") ?? ""

        let targetPathComponents = targetPath
            .components(separatedBy: "/")
            .filter { !$0.isEmpty }

        let schemePath = schemePath
            .prepending(contentsOf: targetPathComponents)
            .filter { !$0.isEmpty }
            .joined(separator: "/")

        let renderDestination = parameters.render.destination.appending(path: filePath)

        if let internalEvent = event.internal, (internalEvent.platform ?? .iOSAndroid) == platform {
            try templateRenderer.renderTemplate(
                parameters.render.internalTemplate,
                to: renderDestination.appending(path: "\(schemeName.camelized)Event.swift"),
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
                    schemeName: schemeName,
                    schemePath: schemePath,
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
                        .isEmpty,
                    isForDesignSystem: event.isForDesignSystem ?? false,
                    isDesignSystem: event.isDesignSystem ?? false,
                    hhtmSource: internalEvent.hhtmSource.map { hhtmSource in
                        InternalEventContext.Parameter(
                            name: hhtmSource.name,
                            description: hhtmSource.description,
                            oneOf: hhtmSource.type.oneOf,
                            const: hhtmSource.type.const,
                            type: hhtmSource.type.swiftType
                        )
                    }
                )
            )
        }

        if let externalEvent = event.external, (externalEvent.platform ?? .iOSAndroid) == platform {
            try templateRenderer.renderTemplate(
                parameters.render.externalTemplate,
                to: renderDestination.appending(path: "\(schemeName.camelized)ExternalEvent.swift"),
                context: ExternalEventContext(
                    edition: event.edition,
                    deprecated: event.deprecated ?? false,
                    name: event.name,
                    description: event.description,
                    category: resolveExternalEventCategory(event: externalEvent),
                    schemeName: schemeName,
                    schemePath: schemePath,
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
                    eventProtocol: resolveEventProtocol(event: externalEvent),
                    initialisationParameters: resolveExternalEventInitialisationParameters(event: externalEvent)
                )
            )
        }
    }

    private func generate(
        configuration: GeneratedConfiguration,
        targetPath: String? = nil,
        schemasPath: URL
    ) async throws {
        guard let enumerator = FileManager.default.enumerator(at: schemasPath, includingPropertiesForKeys: nil) else {
            throw MessageError("Failed to create enumerator at \(schemasPath).")
        }

        Log.info("(\(configuration.name)) Starting code generation... 🚀")

        let generarionParameters = try resolveGenerationParameters(from: configuration)
        let platform = configuration.platform ?? .iOSAndroid

        let events: [(Event, [String])] = try enumerator
            .lazy
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == .yamlExtension }
            .map { url in
                let basePath = schemasPath.standardizedFileURL.path
                let fullPath = url.standardizedFileURL.path

                guard fullPath.hasPrefix(basePath) else {
                    throw MessageError("File path \(fullPath) does not start with base path \(basePath)")
                }

                let relativePath = String(fullPath.dropFirst(basePath.count))
                    .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

                let filePathComponents = relativePath.components(separatedBy: "/")
                let filePath = filePathComponents.joined(separator: "/")

                Log.debug("(\(configuration.name)) Reading schema: \(filePath)")

                do {
                    return try (fileProvider.readFile(at: url.path), filePathComponents)
                } catch {
                    Log.fail("Failed schema: \(filePath)")
                    throw error
                }
            }

        if let destination = configuration.destination {
            try clearDestinationFolder(at: destination)
        }

        try await events.concurrentForEach { event, schemePath in
            do {
                try self.generate(
                    parameters: generarionParameters,
                    event: event,
                    targetPath: targetPath ?? "",
                    schemePath: schemePath,
                    platform: platform
                )
            } catch {
                let filePath = schemePath.joined(separator: "/")
                Log.fail("Failed to generate event using path: \(filePath)")
                throw error
            }
        }
    }

    private func syncAndValidateGitBranches(
        currentRepoPath: String,
        analyticsRepoPath: String,
        analyticsCurrentBranch: String,
        analyticsBaseBranch: String,
        destinations: [String]
    ) throws {
        Log.info("Syncing and validating git branches...")

        let isCurrentBehindDevelop = try branchSynchronizer.isBranchBehind(
            repoPath: currentRepoPath,
            currentBranch: nil,
            baseBranch: "develop"
        )

        // Мерджить аналитику при коде, отстающем от develop, нельзя: события сгенерируются не от того диффа.
        if !isCurrentBehindDevelop {
            try branchSynchronizer.sync(
                repoPath: analyticsRepoPath,
                currentBranch: analyticsCurrentBranch,
                baseBranch: analyticsBaseBranch
            )
        }

        let isAnalyticsBehind = try branchSynchronizer.isBranchBehind(
            repoPath: analyticsRepoPath,
            currentBranch: nil,
            baseBranch: analyticsBaseBranch
        )

        if !isCurrentBehindDevelop, isAnalyticsBehind {
            throw MessageError(
                """
                ❌ Analytics branch is behind '\(analyticsBaseBranch)'.
                Please update the analytics branch before generating code.
                """
            )
        }

        if isCurrentBehindDevelop, !isAnalyticsBehind {
            // Пустые destinations — генерация в консоль, чужим сгенерированным файлам неоткуда взяться в PR.
            let hasForeignDestinationCommits = destinations.isEmpty
                ? false
                : try branchSynchronizer.isBranchBehind(
                    repoPath: currentRepoPath,
                    currentBranch: nil,
                    baseBranch: "develop",
                    paths: destinations
                )

            if hasForeignDestinationCommits {
                throw MessageError(
                    """
                    ❌ Analytics destinations in 'origin/develop' contain commits not in HEAD.
                    Please sync your working branch with 'develop' before generating to avoid pulling those generated files into your PR.
                    Checked destinations: \(destinations.joined(separator: ", "))
                    """
                )
            } else {
                Log.info("ℹ️ Current branch is behind 'develop', but destinations are untouched — continuing.")
            }
        }

        if isAnalyticsBehind, isCurrentBehindDevelop {
            Log.debug("⚠️ Both branches are behind their base branches, but continuing anyway...")
        }

        Log.info("✅ Git branch validation passed")
    }
}

// MARK: - EventGenerator

extension DefaultEventGenerator: EventGenerator {

    func generate(configuration: Configuration, branch: String?) async throws {
        switch configuration.source {
        case let .local(path):
            Log.info("Using local schemas: \(path)")

            try await configuration.generatedConfigurations.concurrentForEach { generatedConfiguration in
                try await self.generate(
                    configuration: generatedConfiguration,
                    targetPath: generatedConfiguration.path,
                    schemasPath: URL(fileURLWithPath: path).appendingPathComponent(generatedConfiguration.path)
                )
            }

        case let .remoteRepo(repoConfiguration):
            let branchName = "\(branch ?? repoConfiguration.defaultBranch)-\(repoConfiguration.branchSuffix)"
            Log.info("Using remote repository: \(repoConfiguration.owner)/\(repoConfiguration.repo) (branch: \(branchName))")

            let repoLocalURL = try await remoteRepoProvider.fetchRepo(
                owner: repoConfiguration.owner,
                repo: repoConfiguration.repo,
                ref: .branch(name: branchName),
                token: repoConfiguration.accessToken.resolveToken()
            )

            try syncAndValidateGitBranches(
                currentRepoPath: Path.current.string,
                analyticsRepoPath: repoLocalURL.path,
                analyticsCurrentBranch: branchName,
                analyticsBaseBranch: "\(repoConfiguration.defaultBranch)-\(repoConfiguration.branchSuffix)",
                destinations: configuration.destinations
            )

            try await configuration.generatedConfigurations.concurrentForEach { generatedConfiguration in
                try await self.generate(
                    configuration: generatedConfiguration,
                    targetPath: generatedConfiguration.path,
                    schemasPath: repoLocalURL.appendingPathComponent(generatedConfiguration.path)
                )
            }
        }
    }
}

// MARK: - GenerationParametersResolving

extension DefaultEventGenerator: GenerationParametersResolving {

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

private extension RenderDestination {

    func appending(path: String) -> Self {
        switch self {
        case let .file(filePath):
            return .file(path: filePath.appending("/\(path)"))

        case .console:
            return self
        }
    }
}

private extension String {

    static let yamlExtension = "yaml"
    static let rootPath = "./"
}
