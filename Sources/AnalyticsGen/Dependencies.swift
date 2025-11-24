import Foundation
import AnalyticsGenTools
import DictionaryCoder

enum Dependencies {

    static let httpService = HTTPService()

    static let remoteRepoProvider: RemoteRepoProvider = ForgejoRemoteRepoProvider(
        baseURL: URL(string: "https://forgejo.pyn.ru/api/v1")!
    )

    static let yamlFileProvider: FileProvider = YAMLFileProvider()

    static let templateContextCoder: TemplateContextCoder = DefaultTemplateContextCoder()

    static let stencilExtensions: [StencilExtension] = [
        StencilStringUppercasePrefixFilter(),
        StencilStringUppercaseSuffixFilter(),
        StencilStringMultilineFilter(),
        StencilStringMultilineAlignmentFilter()
    ]

    static let templateRenderer: TemplateRenderer = DefaultTemplateRenderer(
        contextCoder: templateContextCoder,
        stencilExtensions: stencilExtensions
    )

    static let eventGenerator: EventGenerator = DefaultEventGenerator(
        fileProvider: yamlFileProvider,
        remoteRepoProvider: remoteRepoProvider,
        templateRenderer: templateRenderer,
        dictionaryDecoder: DictionaryDecoder()
    )
}
