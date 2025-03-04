enum GitReferenceType: Equatable {
    case tag(name: String)
    case branch(name: String)
    case commit(sha: String)

    var rawValue: String {
        switch self {
        case .tag(let name):
            return "tags/\(name)"

        case .branch(let name):
            return "heads/\(name)"

        case .commit(let sha):
            return sha
        }
    }

    var nameValue: String {
        switch self {
        case .tag(let name), .branch(let name):
            return name

        case .commit(let sha):
            return sha
        }
    }
}
