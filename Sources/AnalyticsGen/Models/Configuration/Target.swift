import Foundation
import AnalyticsGenTools

struct Target: Decodable {
    
    let name: String
    let platform: EventPlatform?
    let path: String?
    let destination: String?
    let ref: GitHubReferenceConfiguration?
}
