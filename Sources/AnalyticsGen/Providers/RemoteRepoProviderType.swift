enum RemoteRepoProviderType: String {
    case forgejo
    case github
    
    static func from(string: String) throws -> Self {
        switch string.lowercased() {
        case "forgejo":
            return .forgejo
        case "github":
            return .github
        default:
            throw DependeciesGeneratorError.unknownProvider
        }
    }
}
