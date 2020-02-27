//
//  Dependencies.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation
import AnalyticsGenTools

enum Dependencies {

    // MARK: - Type Properties

    static let analyticsGenHTTPService: AnalyticsGenHTTPService = HTTPService()

    // MARK: -

    static let analyticsGenAPIProvider: AnalyticsGenAPIProvider = DefaultAnalyticsGenAPIProvider(
        httpService: Dependencies.analyticsGenHTTPService
    )

    static let analyticsTrackersProvider: AnalyticsTrackersProvider = DefaultAnalyticsTrackersProvider(
        apiProvider: Dependencies.analyticsGenAPIProvider
    )

    // MARK: -

    static let decodableTracker: DecodableCoder = DefaultDecodableCoder()
    static let trackerCoder: TrackerCoder = DefaultTrackerCoder(decodableCoder: Dependencies.decodableTracker)

    // MARK: -

    static let templateRenderer: TemplateRenderer = DefaultTemplateRenderer()

    // MARK: -

    static let trackersGenerator: TrackersGenerator = DefaultTrackersGenerator(
        analyticsTrackersProvider: Dependencies.analyticsTrackersProvider,
        trackerCoder: Dependencies.trackerCoder,
        templateRenderer: Dependencies.templateRenderer
    )
}
