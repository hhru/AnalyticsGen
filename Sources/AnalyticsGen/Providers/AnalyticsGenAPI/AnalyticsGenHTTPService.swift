//
//  AnalyticsGenHTTPService.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import AnalyticsGenTools

protocol AnalyticsGenHTTPService {

    // MARK: - Instance Methods

    func request(route: HTTPRoute) -> HTTPTask
}

// MARK: - HTTPService

extension HTTPService: AnalyticsGenHTTPService { }
