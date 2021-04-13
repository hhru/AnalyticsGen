import Foundation
import AnalyticsGenTools
import DictionaryCoder

enum Dependencies {

    // MARK: - Type Properties

    static let configurationProvider: ConfigurationProvider = DefaultConfigurationProvider()
    static let specificationProvider: SpecificationProvider = DefaultSpecificationProvider()
    static let schemaProvider: SchemaProvider = DefaultSchemaProvider()

    static let templateContextCoder: TemplateContextCoder = DefaultTemplateContextCoder()
    static let stencilExtensions: [StencilExtension] = []

    static let templateRenderer: TemplateRenderer = DefaultTemplateRenderer(
        contextCoder: templateContextCoder,
        stencilExtensions: stencilExtensions
    )

    static let eventGenerator: EventGenerator = DefaultEventGenerator(
        configurationProvider: configurationProvider,
        specificationProvider: specificationProvider,
        schemaProvider: schemaProvider,
        templateRenderer: templateRenderer,
        dictionaryDecoder: DictionaryDecoder()
    )
}
