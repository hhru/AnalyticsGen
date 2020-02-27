//
//  GenerationParametersResolving.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation

protocol GenerationParametersResolving {

    // MARK: - Instance Properties

    var defaultTemplateType: RenderTemplateType { get }
    var defaultDestination: RenderDestination { get }

    // MARK: - Instance Methods

    func resolveGenerationParameters(from configuration: GenerationConfiguration) throws -> GenerationParameters
}

// MARK: -

extension GenerationParametersResolving {

    // MARK: - Instance Methods

    func resolveTemplateType(from configuration: GenerationConfiguration) -> RenderTemplateType {
        if let templatePath = configuration.template {
            return .custom(path: templatePath)
        } else {
            return self.defaultTemplateType
        }
    }

    func resolveDestination(from configuration: GenerationConfiguration) -> RenderDestination {
        if let destinationPath = configuration.destination {
            return .file(path: destinationPath)
        } else {
            return self.defaultDestination
        }
    }

    // MARK: -

    func resolveGenerationParameters(from configuration: GenerationConfiguration) throws -> GenerationParameters {
        let templateType = self.resolveTemplateType(from: configuration)
        let destination = self.resolveDestination(from: configuration)

        let template = RenderTemplate(type: templateType, options: configuration.templateOptions ?? [:])
        let render = RenderParameters(template: template, destination: destination)

        return GenerationParameters(render: render)
    }
}
