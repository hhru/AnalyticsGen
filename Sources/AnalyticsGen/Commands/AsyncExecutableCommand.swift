//
//  AsyncExecutableCommand.swift
//  AnalyticsGen
//
//  Created by Timur Shafigullin on 12/01/2020.
//

import Foundation
import SwiftCLI
import Rainbow

protocol AsyncExecutableCommand: Command {

    // MARK: - Instance Methods

    func executeAsyncAndExit() throws

    func fail(message: String) -> Never
    func succeed(message: String) -> Never
}

// MARK: -

extension AsyncExecutableCommand {

    // MARK: - Instance Methods

    func execute() throws {
        try self.executeAsyncAndExit()

        RunLoop.main.run()
    }

    func fail(message: String) -> Never {
        self.stderr <<< message.red

        exit(EXIT_FAILURE)
    }

    func succeed(message: String) -> Never {
        self.stdout <<< message.green

        exit(EXIT_SUCCESS)
    }
}
