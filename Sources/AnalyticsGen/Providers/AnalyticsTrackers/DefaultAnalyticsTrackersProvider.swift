//
//  DefaultAnalyticsTrackersProvider.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import PromiseKit

final class DefaultAnalyticsTrackersProvider: AnalyticsTrackersProvider {

    // MARK: - Instance Properties

    private let apiProvider: AnalyticsGenAPIProvider

    // MARK: - Initializers

    init(apiProvider: AnalyticsGenAPIProvider) {
        self.apiProvider = apiProvider
    }

    // MARK: - AnalyticsTrackersProvider

    func fetchAnalyticsTrackers() -> Promise<GenerationDTO> {
        let route = AnalyticsGenAPITrackerRoute()

        let promise = firstly {
            self.apiProvider.request(route: route)
        }

        return promise
    }
}
