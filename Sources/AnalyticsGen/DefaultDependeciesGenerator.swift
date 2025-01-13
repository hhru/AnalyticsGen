import Foundation
import AnalyticsGenTools
import DictionaryCoder

final class DefaultDependeciesGenerator: DependenciesGenerator {
    let httpService: HTTPService
    let yamlFileProvider: FileProvider
    let templateContextCoder: TemplateContextCoder
    let stencilExtensions: [StencilExtension]
    let templateRenderer: TemplateRenderer
    
    init() {
        self.httpService = HTTPService()
        self.yamlFileProvider = YAMLFileProvider()
        self.templateContextCoder = DefaultTemplateContextCoder()
        self.stencilExtensions = [
            StencilStringUppercasePrefixFilter(),
            StencilStringUppercaseSuffixFilter(),
            StencilStringMultilineFilter(),
            StencilStringMultilineAlignmentFilter()
        ]
        self.templateRenderer = DefaultTemplateRenderer(
            contextCoder: templateContextCoder,
            stencilExtensions: stencilExtensions
        )
    }
    
    func createGenerator(for provider: String) throws -> EventGenerator {
        let repoProviderType = RemoteRepoProviderType.from(string: provider)
        
        var remoteRepoProvider: RemoteRepoProvider?
        
        switch repoProviderType {
        case .forgejo:
            remoteRepoProvider = ForgejoRemoteRepoProvider(httpService: httpService)
        case .github:
            remoteRepoProvider = GitHubRemoteRepoProvider(httpService: httpService)
        case .unknown:
            throw DependeciesGeneratorError.unknownProvider
        }
        
        guard let remoteRepoProvider = remoteRepoProvider else {
            throw DependeciesGeneratorError.unknownProvider
        }
        
        let remoteRepoReferenceFinder = RemoteRepoReferenceFinder(remoteRepoProvider: remoteRepoProvider)

        return DefaultEventGenerator(
            fileProvider: yamlFileProvider,
            remoteRepoProvider: remoteRepoProvider,
            templateRenderer: templateRenderer,
            dictionaryDecoder: DictionaryDecoder(),
            remoteRepoReferenceFinder: remoteRepoReferenceFinder
        )
    }
}

enum DependeciesGeneratorError: Error {
    case unknownProvider
    
    var errorDescription: String {
        switch self {
        case .unknownProvider:
            "The specified remote repository provider is unknown"
        }
    }
}
