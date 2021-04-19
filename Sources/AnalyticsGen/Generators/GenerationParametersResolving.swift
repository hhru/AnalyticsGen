import Foundation

protocol GenerationParametersResolving {

    // MARK: - Instance Properties

    var defaultInternalTemplateType: RenderTemplateType { get }
    var defaultExternalTemplateType: RenderTemplateType { get }
    var defaultDestination: RenderDestination { get }

    // MARK: - Instance Methods

    func resolveGenerationParameters(from configuration: Configuration) throws -> GenerationParameters
}

// MARK: -

extension GenerationParametersResolving {

    // MARK: - Instance Methods

    private func resolveInternalTemplateType(configuration: Configuration) -> RenderTemplateType {
        if let templatesPath = configuration.template?.internal?.path {
            return .custom(path: templatesPath)
        } else {
            return defaultInternalTemplateType
        }
    }

    private func resolveExternalTemplateType(configuration: Configuration) -> RenderTemplateType {
        if let templatesPath = configuration.template?.external?.path {
            return .custom(path: templatesPath)
        } else {
            return defaultExternalTemplateType
        }
    }

    private func resolveDestination(configuration: Configuration) -> RenderDestination {
        if let destinationPath = configuration.destination {
            return .file(path: destinationPath)
        } else {
            return defaultDestination
        }
    }

    // MARK: -

    func resolveGenerationParameters(from configuration: Configuration) throws -> GenerationParameters {
        let internalTemplateType = resolveInternalTemplateType(configuration: configuration)
        let externalTemplateType = resolveExternalTemplateType(configuration: configuration)

        let internalTemplate = RenderTemplate(
            type: internalTemplateType,
            options: configuration
                .template?
                .internal?
                .options?
                .mapValues { $0.value } ?? [:]
        )

        let externalTemplate = RenderTemplate(
            type: externalTemplateType,
            options: configuration
            .template?
            .external?
            .options?
            .mapValues { $0.value } ?? [:]
        )

        let destination = resolveDestination(configuration: configuration)

        let render = RenderParameters(
            internalTemplate: internalTemplate,
            externalTemplate: externalTemplate,
            destination: destination
        )

        return GenerationParameters(render: render)
    }
}
