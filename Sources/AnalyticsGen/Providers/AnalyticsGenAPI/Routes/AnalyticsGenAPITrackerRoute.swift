//
//  AnalyticsGenAPITrackerRoute.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 18/01/2020.
//

import Foundation

struct AnalyticsGenAPITrackerRoute: AnalyticsGenAPIRoute {

    // MARK: - Nested Types

    typealias Response = [Tracker]
    typealias QueryParameters = AnalyticsGenAPIEmptyParameters
    typealias BodyParameters = AnalyticsGenAPIEmptyParameters

    // MARK: - Instance Properties

    var urlPath: String {
        "tracker"
    }
}
