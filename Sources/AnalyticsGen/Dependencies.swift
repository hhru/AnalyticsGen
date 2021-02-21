import Foundation
import AnalyticsGenTools

enum Dependencies {

    // MARK: - Type Properties

    static let configurationProvider: ConfigurationProvider = DefaultConfigurationProvider()
    static let eventGenerator: EventGenerator = DefaultEventGenerator(configurationProvider: configurationProvider)
}
