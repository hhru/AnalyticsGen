import Foundation

enum DependeciesGeneratorError: Error {
    case unknownProvider
    case invalidRemoteHostURI
    
    var errorDescription: String {
        switch self {
        case .unknownProvider:
            "The specified remote repository provider is unknown"
        case .invalidRemoteHostURI:
            "The remote repository URI is not correct"
        }
    }
}
