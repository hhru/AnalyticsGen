import AnalyticsGenTools

protocol DependenciesGenerator {
    var httpService: HTTPService { get }
    var yamlFileProvider: FileProvider { get }
    var templateContextCoder: TemplateContextCoder { get }
    var stencilExtensions: [StencilExtension] { get }
    var templateRenderer: TemplateRenderer { get }
    
    func createGenerator(for provider: String, remoteHost: String) throws -> EventGenerator
}
