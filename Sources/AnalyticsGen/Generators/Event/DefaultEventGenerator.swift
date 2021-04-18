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

    private func generate(parameters: GenerationParameters, event: Event, schemaURL: URL) throws {
        let filename = schemaURL.deletingPathExtension().lastPathComponent.camelized.appending(String.filenameSuffix)
        let context = EventContext(event: event, filename: filename)

        try templateRenderer.renderTemplate(
            parameters.render.template,
            to: parameters.render.destination.appending(path: "\(filename).swift"),
            context: context
        )
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

        let generarionParameters = try resolveGenerationParameters(from: configuration)

        for case let schemaURL as URL in enumerator where schemaURL.pathExtension == "yaml" {
            let path = schemaURL.path
            let schema = try schemaProvider.fetchSchema(from: path)

            Log.info("Validating file \(path)")

            // Возможно, валидация схемы не нужна, так как ниже декодим по модели Event,
            // которая описывает спецификацию
            if let errors = JSONSchema.validate(schema, schema: specification).errors {
                throw MessageError(errors.joined(separator: "\n"))
            }

            let event = try dictionaryDecoder.decode(Event.self, from: schema)

            Log.success("File \(path) is valid. Start generating...")

            try generate(parameters: generarionParameters, event: event, schemaURL: schemaURL)
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

// MARK: - GenerationParametersResolving

extension DefaultEventGenerator: GenerationParametersResolving {

    // MARK: - Instance Properties

    var defaultTemplateType: RenderTemplateType {
        .native(name: "Event")
    }

    var defaultDestination: RenderDestination {
        .console
    }
}

// MARK: -

private extension RenderDestination {

    // MARK: - Instance Methods

    func appending(path: String) -> Self {
        switch self {
        case .file(let filePath):
            return .file(path: filePath.appending("/\(path)"))

        case .console:
            return self
        }
    }
}

// MARK: -

private extension String {

    // MARK: - Type Properties

    static let filenameSuffix = "Event"
}
