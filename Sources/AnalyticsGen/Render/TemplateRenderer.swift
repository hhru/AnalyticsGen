//
//  TemplateRenderer.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 18/01/2020.
//

import Foundation

protocol TemplateRenderer {

    // MARK: - Instance Methods

    func render(template: RenderTemplate, to destination: RenderDestination, context: [String: Any]) throws
}
