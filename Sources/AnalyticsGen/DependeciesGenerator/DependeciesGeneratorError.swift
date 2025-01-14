import Foundation

enum DependeciesGeneratorError: Error {
    case unknownProvider
    case missingRemoteHostURI
    
    var errorDescription: String {
        switch self {
        case .unknownProvider:
            "The specified remote repository provider is unknown"
        case .missingRemoteHostURI:
            "The remote repository URI is not specified or incorrect"
        }
    }
}
