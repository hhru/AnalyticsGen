import Foundation
import AnalyticsGenTools
import DictionaryCoder

enum Dependencies {

    // MARK: - Type Properties

    static let httpService = HTTPService()

    static let gitHubRemoteRepoProvider: RemoteRepoProvider = GitHubRemoteRepoProvider(httpService: httpService)
    static let yamlFileProvider: FileProvider = YAMLFileProvider()
    static let remoteRepoReferenceFinder = RemoteRepoReferenceFinder(remoteRepoProvider: gitHubRemoteRepoProvider)

    static let templateContextCoder: TemplateContextCoder = DefaultTemplateContextCoder()

    static let stencilExtensions: [StencilExtension] = [
        StencilStringUpperWordFilter(),
        StencilStringMultilineFilter(),
        StencilStringMultilineAlignmentFilter()
    ]

    static let templateRenderer: TemplateRenderer = DefaultTemplateRenderer(
        contextCoder: templateContextCoder,
        stencilExtensions: stencilExtensions
    )

    static let eventGenerator: EventGenerator = DefaultEventGenerator(
        fileProvider: yamlFileProvider,
        remoteRepoProvider: gitHubRemoteRepoProvider,
        templateRenderer: templateRenderer,
        dictionaryDecoder: DictionaryDecoder(),
        remoteRepoReferenceFinder: remoteRepoReferenceFinder
    )
}
