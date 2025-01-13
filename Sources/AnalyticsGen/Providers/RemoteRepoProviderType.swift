enum RemoteRepoProviderType: String {
    case forgejo = "forgejo"
    case github = "github"
    case unknown
    
    static func from(string: String) -> Self {
        switch string.lowercased() {
        case "forgejo":
            return .forgejo
        case "github":
            return .github
        default:
            return .unknown
        }
    }
}
