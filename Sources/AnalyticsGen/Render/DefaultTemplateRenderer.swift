//
//  DefaultTemplateRenderer.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation
import PathKit
import Stencil
import StencilSwiftKit

final class DefaultTemplateRenderer: TemplateRenderer {

    // MARK: - Nested Types

    private enum Constants {

        // MARK: - Type Properties

        static let templatesFileExtension = ".stencil"
        static let templatesXcodeRelativePath = "../Templates"
        static let templatesPodsRelativePath = "../Templates"
        static let templatesShareRelativePath = "../../share/fugen"
        static let templateOptionsKey = "options"
    }

    // MARK: - Instance Methods

    private func resolveTemplatePath(of templateType: RenderTemplateType) throws -> Path {
        switch templateType {
        case let .native(name: templateName):
            let templateFileName = templateName.appending(Constants.templatesFileExtension)

            #if DEBUG
            let xcodeTemplatesPath = Path.current.appending(Constants.templatesXcodeRelativePath)

            if xcodeTemplatesPath.exists {
                return xcodeTemplatesPath.appending(templateFileName)
            }
            #endif

            var executablePath = Path(ProcessInfo.processInfo.executablePath)

            while executablePath.isSymlink {
                executablePath = try executablePath.symlinkDestination()
            }

            let podsTemplatesPath = executablePath.appending(Constants.templatesPodsRelativePath)

            if podsTemplatesPath.exists {
                return podsTemplatesPath.appending(templateFileName)
            }

            return executablePath.appending(Constants.templatesShareRelativePath).appending(templateFileName)

        case let .custom(path: templatePath):
            return Path(templatePath)
        }
    }

    private func write(output: String, to destination: RenderDestination) throws {
        switch destination {
        case let .file(path: filePath):
            let filePath = Path(filePath)

            try filePath.parent().mkpath()
            try filePath.write(output)

        case .console:
            print(output)
        }
    }

    // MARK: - TemplateRenderer

    func render(template: RenderTemplate, to destination: RenderDestination, context: [String: Any]) throws {
        let templatePath = try self.resolveTemplatePath(of: template.type)

        let stencilEnvironment = Environment(
            loader: FileSystemLoader(paths: [templatePath.parent()]),
            templateClass: StencilSwiftTemplate.self
        )

        let stencilTemplate = StencilSwiftTemplate(
            templateString: try templatePath.read(),
            environment: stencilEnvironment
        )

        let context = context.merging([Constants.templateOptionsKey: template.options], uniquingKeysWith: { $1 })
        let output = try stencilTemplate.render(context)

        try self.write(output: output, to: destination)
    }
}
