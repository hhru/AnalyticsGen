import Foundation
import PromiseKit
import Yams
import AnalyticsGenTools
import JSONSchema
import DictionaryCoder

final class DefaultEventGenerator: EventGenerator {

    // MARK: - Instance Properties

    let configurationProvider: ConfigurationProvider
    let specificationProvider: SpecificationProvider
    let schemaProvider: SchemaProvider
    let templateRenderer: TemplateRenderer
    let dictionaryDecoder: DictionaryDecoder

    // MARK: - Initializers

    init(
        configurationProvider: ConfigurationProvider,
        specificationProvider: SpecificationProvider,
        schemaProvider: SchemaProvider,
        templateRenderer: TemplateRenderer,
        dictionaryDecoder: DictionaryDecoder
    ) {
        self.configurationProvider = configurationProvider
        self.specificationProvider = specificationProvider
        self.schemaProvider = schemaProvider
        self.templateRenderer = templateRenderer
        self.dictionaryDecoder = dictionaryDecoder
    }

    private func generate(event: Event, outputPath: String) {
        print(event)
    }

    private func generate(configuration: Configuration, specification: Specification) throws {
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

            // Возможно, валидация схемы не нужна, так как ниже декодим по модели Event,
            // которая описывает спецификацию
            if let errors = JSONSchema.validate(schema, schema: specification).errors {
                throw MessageError(errors.joined(separator: "\n"))
            }

            let event = try dictionaryDecoder.decode(Event.self, from: schema)

            Log.success("File \(path) is valid")

            generate(event: event, outputPath: "")
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
            try self.generate(configuration: configuration, specification: specification)
        }
    }
}
