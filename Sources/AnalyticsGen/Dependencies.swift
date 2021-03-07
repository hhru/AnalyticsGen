import Foundation
import AnalyticsGenTools

enum Dependencies {

    // MARK: - Type Properties

    static let configurationProvider: ConfigurationProvider = DefaultConfigurationProvider()
    static let specificationProvider: SpecificationProvider = DefaultSpecificationProvider()
    static let schemaProvider: SchemaProvider = DefaultSchemaProvider()

    static let eventGenerator: EventGenerator = DefaultEventGenerator(
        configurationProvider: configurationProvider,
        specificationProvider: specificationProvider,
        schemaProvider: schemaProvider
    )
}
