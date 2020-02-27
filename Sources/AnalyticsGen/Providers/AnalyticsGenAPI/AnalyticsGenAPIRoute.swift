//
//  AnalyticsGenAPIRoute.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import AnalyticsGenTools

protocol AnalyticsGenAPIRoute {

    // MARK: - Nested Types

    associatedtype QueryParameters: Encodable
    associatedtype BodyParameters: Encodable
    associatedtype Response: Decodable

    // MARK: - Instance Properties

    var apiVersion: AnalyticsGenAPIVersion { get }
    var httpMethod: HTTPMethod { get }
    var urlPath: String { get }
    var accessToken: String? { get }
    var queryParameters: QueryParameters? { get }
    var bodyParameters: BodyParameters? { get }
}

// MARK: -

extension AnalyticsGenAPIRoute {

    // MARK: - Instance Properties

    var apiVersion: AnalyticsGenAPIVersion {
        .v1
    }

    var httpMethod: HTTPMethod {
        .get
    }

    var accessToken: String? {
        nil
    }
}

// MARK: -

extension AnalyticsGenAPIRoute where QueryParameters == AnalyticsGenAPIEmptyParameters {

    // MARK: - Instance Properties

    var queryParameters: QueryParameters? {
        nil
    }
}

// MARK: -

extension AnalyticsGenAPIRoute where BodyParameters == AnalyticsGenAPIEmptyParameters {

    // MARK: - Instance Properties

    var bodyParameters: BodyParameters? {
        nil
    }
}
