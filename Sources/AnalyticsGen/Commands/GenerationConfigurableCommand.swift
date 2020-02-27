//
//  GenerationConfigurableCommand.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation
import SwiftCLI

protocol GenerationConfigurableCommand: Command {

    // MARK: - Instance Properties

    var template: Key<String> { get }
    var destination: Key<String> { get }

    var generationConfiguration: GenerationConfiguration { get }
}

// MARK: -

extension GenerationConfigurableCommand {

    // MARK: - Instance Properties

    var generationConfiguration: GenerationConfiguration {
        GenerationConfiguration(template: template.value, templateOptions: nil, destination: self.destination.value)
    }
}
