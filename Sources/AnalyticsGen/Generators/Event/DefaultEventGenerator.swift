import Foundation
import PromiseKit

final class DefaultEventGenerator: EventGenerator {

    // MARK: - Instance Properties

    let configurationProvider: ConfigurationProvider

    // MARK: - Initializers

    init(configurationProvider: ConfigurationProvider) {
        self.configurationProvider = configurationProvider
    }

    // MARK: - EventGenerator

    func generate(configurationPath: String) -> Promise<Void> {
        firstly {
            configurationProvider.fetchConfiguration(from: configurationPath)
        }.done { configuration in
            print(configuration)
        }
    }
}
