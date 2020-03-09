//
//  DefaultTrackersGenerator.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import AnalyticsGenTools
import PromiseKit
import DictionaryCoder

final class DefaultTrackersGenerator: TrackersGenerator, GenerationParametersResolving {

    // MARK: - Instance Properties

    let analyticsTrackersProvider: AnalyticsTrackersProvider
    let templateRenderer: TemplateRenderer

    // MARK: -

    let defaultTemplateType: RenderTemplateType = .native(name: "Trackers")
    let defaultDestination: RenderDestination = .console

    // MARK: - Initializers

    init(
        analyticsTrackersProvider: AnalyticsTrackersProvider,
        templateRenderer: TemplateRenderer
    ) {
        self.analyticsTrackersProvider = analyticsTrackersProvider
        self.templateRenderer = templateRenderer
    }

    // MARK: - Instance Methods

    private func generate(parameters: GenerationParameters) -> Promise<Void> {
        return firstly {
            self.analyticsTrackersProvider.fetchAnalyticsTrackers()
        }.done { generationDTO in
            let context = try DictionaryEncoder().encode(generationDTO)

            try self.templateRenderer.render(
                template: parameters.render.template,
                to: parameters.render.destination,
                context: context
            )
        }
    }

    // MARK: - TrackersGenerator

    func generate(configuration: GenerationConfiguration) -> Promise<Void> {
        return perform(on: DispatchQueue.global(qos: .userInitiated)) {
            try self.resolveGenerationParameters(from: configuration)
        }.then { parameters in
            self.generate(parameters: parameters)
        }
    }
}
