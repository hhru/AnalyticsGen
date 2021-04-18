import Foundation

protocol GenerationParametersResolving {

    // MARK: - Instance Properties

    var defaultTemplateType: RenderTemplateType { get }
    var defaultDestination: RenderDestination { get }

    // MARK: - Instance Methods

    func resolveGenerationParameters(from configuration: Configuration) throws -> GenerationParameters
}

// MARK: -

extension GenerationParametersResolving {

    // MARK: - Instance Methods

    private func resolveTemplateType(configuration: Configuration) -> RenderTemplateType {
        if let templatePath = configuration.template {
            return .custom(path: templatePath)
        } else {
            return defaultTemplateType
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
        let templateType = resolveTemplateType(configuration: configuration)
        let destination = resolveDestination(configuration: configuration)

        let template = RenderTemplate(
            type: templateType,
            options: configuration
                .templateOptions?
                .mapValues { $0.value } ?? [:]
        )

        let render = RenderParameters(template: template, destination: destination)

        return GenerationParameters(render: render)
    }
}
