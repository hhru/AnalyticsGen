import Foundation
import PromiseKit

protocol EventGenerator {

    // MARK: - Instance Methods

    func generate(configurationPath: String, force: Bool) -> Promise<EventGenerationResult>
}
