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
    
    func createGenerator(for provider: String, remoteHost: String) throws -> EventGenerator {
        
        guard let baseURL = URL(string: remoteHost) else {
           throw DependeciesGeneratorError.missingRemoteHostURI
        }
        
        let repoProviderType = try RemoteRepoProviderType.from(string: provider)
        
        var remoteRepoProvider: RemoteRepoProvider?
        
        switch repoProviderType {
        case .forgejo:
            remoteRepoProvider = ForgejoRemoteRepoProvider(baseURL: baseURL, httpService: httpService)
        case .github:
            remoteRepoProvider = GitHubRemoteRepoProvider(baseURL: baseURL, httpService: httpService)
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
