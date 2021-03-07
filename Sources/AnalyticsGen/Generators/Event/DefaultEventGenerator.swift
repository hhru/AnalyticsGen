import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema

final class DefaultEventGenerator: EventGenerator {

    // MARK: - Instance Properties

    let configurationProvider: ConfigurationProvider
    let specificationProvider: SpecificationProvider
    let schemaProvider: SchemaProvider

    // MARK: - Initializers

    init(
        configurationProvider: ConfigurationProvider,
        specificationProvider: SpecificationProvider,
        schemaProvider: SchemaProvider
    ) {
        self.configurationProvider = configurationProvider
        self.specificationProvider = specificationProvider
        self.schemaProvider = schemaProvider
    }

    private func validateSchemas(configuration: Configuration, specification: Specification) throws {
        guard let schemasPath = configuration.source?.local else {
            return
        }

        guard let enumerator = FileManager.default.enumerator(
                at: URL(fileURLWithPath: schemasPath),
                includingPropertiesForKeys: nil
        ) else {
            return
        }

        for case let schemaURL as URL in enumerator where schemaURL.pathExtension == "yaml" {
            let path = schemaURL.path

            Log.info("Validating file \(path)")

            let schema = try schemaProvider.fetchSchema(from: path)

            if let errors = JSONSchema.validate(schema, schema: specification).errors {
                throw MessageError(errors.joined(separator: "\n"))
            }

            Log.success("File \(path) is valid")
        }
    }

    // MARK: - EventGenerator

    func generate(configurationPath: String) -> Promise<Void> {
        firstly {
            configurationProvider.fetchConfiguration(from: configurationPath)
        }.then { configuration in
            self.specificationProvider
                .fetchSpecification(from: configuration.specification)
                .map { (configuration, $0) }
        }.done { configuration, specification in
            try self.validateSchemas(configuration: configuration, specification: specification)
        }
    }
}
