enum GitReferenceType: Equatable {
    case tag(name: String)
    case branch(name: String)
    case commit(id: String)

    var rawValue: String {
        switch self {
        case .tag(let name):
            return "tags/\(name)"

        case .branch(let name):
            return "heads/\(name)"

        case .commit(let id):
            return id
        }
    }
}
