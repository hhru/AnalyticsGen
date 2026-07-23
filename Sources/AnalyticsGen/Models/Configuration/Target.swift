import Foundation
import AnalyticsGenTools

struct Target: Decodable, Equatable {
    
    let name: String
    let path: String
    let destination: String?
}
