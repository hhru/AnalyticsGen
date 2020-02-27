//
//  DefaultAnalyticsGenAPIProvider.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import PromiseKit
import AnalyticsGenTools

final class DefaultAnalyticsGenAPIProvider: AnalyticsGenAPIProvider {

    // MARK: - Instance Properties

    private let queryEncoder: HTTPQueryEncoder
    private let bodyEncoder: HTTPBodyEncoder
    private let responseDecoder: HTTPResponseDecoder

    // MARK: -

    let httpService: AnalyticsGenHTTPService

    // MARK: - Initializers

    init(httpService: AnalyticsGenHTTPService) {
        self.httpService = httpService

        let urlEncoder = URLEncoder()
        let jsonEncoder = JSONEncoder()
        let jsonDecoder = JSONDecoder()

        self.queryEncoder = HTTPQueryURLEncoder(urlEncoder: urlEncoder)
        self.bodyEncoder = HTTPBodyJSONEncoder(jsonEncoder: jsonEncoder)
        self.responseDecoder = jsonDecoder
    }

    // MARK: - Instance Methods

    private func makeHTTPRoute<Route: AnalyticsGenAPIRoute>(for route: Route) -> HTTPRoute {
        let url = URL.analyticsGenURL
            .appendingPathComponent(route.apiVersion.urlPath)
            .appendingPathComponent(route.urlPath)

        return HTTPRoute(
            method: route.httpMethod,
            url: url,
            queryParameters: route.queryParameters,
            queryEncoder: self.queryEncoder,
            bodyParameters: route.bodyParameters,
            bodyEncoder: self.bodyEncoder
        )
    }

    // MARK: - AnalyticsGenAPIProvider

    func request<Route>(route: Route) -> Promise<Route.Response> where Route: AnalyticsGenAPIRoute {
        return Promise(resolver: { seal in
            let task = self.httpService.request(route: self.makeHTTPRoute(for: route))

            task.responseDecodable(type: Route.Response.self, decoder: self.responseDecoder, completion: { response in
                switch response.result {
                case let .failure(error):
                    seal.reject(error)

                case let .success(value):
                    seal.fulfill(value)
                }
            })
        })
    }
}

// MARK: - URL

private extension URL {

    // MARK: - Type Properties

    static let analyticsGenURL = URL(string: "http://localhost:8080")!
}
