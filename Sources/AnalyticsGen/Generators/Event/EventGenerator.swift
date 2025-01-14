import Foundation
import PromiseKit

protocol EventGenerator {

    // MARK: - Instance Methods

    func generate(configuration: Configuration, force: Bool) -> Promise<EventGenerationResult>
}
