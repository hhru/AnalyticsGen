import Foundation
import PromiseKit

protocol EventGenerator {

    // MARK: - Instance Methods

    func generate(configurationPath: String) -> Promise<Void>
}
