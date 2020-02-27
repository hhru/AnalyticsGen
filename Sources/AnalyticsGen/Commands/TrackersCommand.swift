//
//  TrackersCommand.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 19/01/2020.
//

import Foundation
import SwiftCLI
import PromiseKit

final class TrackersCommand: AsyncExecutableCommand, GenerationConfigurableCommand {

    // MARK: - Instance Properties

    let generator: TrackersGenerator

    // MARK: -

    let name = "trackers"
    let shortDescription = "Generate code for analytics trackers from server"

    // MARK: -

    var template = Key<String>(
        "--template",
        "-t",
        description: """
            Path to the template file.
            If no template is passed a default template will be used.
            """
    )

    let destination = Key<String>(
        "--destination",
        "-d",
        description: """
            The path to the file to generate.
            By default, generated code will be printed on stdout.
            """
    )

    // MARK: - Initializers

    init(generator: TrackersGenerator) {
        self.generator = generator
    }

    // MARK: - AsyncExecutableCommand

    func executeAsyncAndExit() throws {
        firstly {
            self.generator.generate(configuration: self.generationConfiguration)
        }.done {
            self.succeed(message: "Analytics trackers generated successfully!")
        }.catch { error in
            self.fail(message: "Failed to generate analytics trackers: \(error)")
        }
    }
}


