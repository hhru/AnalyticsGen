//
//  DefaultTrackersGenerator.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import AnalyticsGenTools
import PromiseKit

final class DefaultTrackersGenerator: TrackersGenerator, GenerationParametersResolving {

    // MARK: - Instance Properties

    let analyticsTrackersProvider: AnalyticsTrackersProvider
    let trackerCoder: TrackerCoder
    let templateRenderer: TemplateRenderer

    // MARK: -

    let defaultTemplateType: RenderTemplateType = .native(name: "Trackers")
    let defaultDestination: RenderDestination = .console

    // MARK: - Initializers

    init(
        analyticsTrackersProvider: AnalyticsTrackersProvider,
        trackerCoder: TrackerCoder,
        templateRenderer: TemplateRenderer
    ) {
        self.analyticsTrackersProvider = analyticsTrackersProvider
        self.trackerCoder = trackerCoder
        self.templateRenderer = templateRenderer
    }

    // MARK: - Instance Methods

    private func generate(parameters: GenerationParameters) -> Promise<Void> {
        return firstly {
            self.analyticsTrackersProvider.fetchAnalyticsTrackers()
        }.done { trackers in
            let context = self.trackerCoder.encode(trackers: trackers)

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
