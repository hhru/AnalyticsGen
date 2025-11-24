import Foundation

protocol EventGenerator {

    func generate(configuration: Configuration, branch: String?) async throws
}
