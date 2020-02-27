//
//  DefaultTrackerCoder.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation

final class DefaultTrackerCoder: TrackerCoder {

    // MARK: - Instance Properties

    let decodableCoder: DecodableCoder

    // MARK: - Initializers

    init(decodableCoder: DecodableCoder) {
        self.decodableCoder = decodableCoder
    }

    // MARK: - TrackerCoder

    func encode(trackers: [Tracker]) -> [String: Any] {
        let trackersJSON = (try? self.decodableCoder.encode(trackers)) ?? []

        return ["trackers": trackersJSON]
    }
}
