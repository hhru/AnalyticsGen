//
//  AnalyticsGenAPIProvider.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import PromiseKit

protocol AnalyticsGenAPIProvider {

    // MARK: - Instance Methods

    func request<Route: AnalyticsGenAPIRoute>(route: Route) -> Promise<Route.Response>
}
