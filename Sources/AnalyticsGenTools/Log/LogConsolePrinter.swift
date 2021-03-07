import Foundation
import SwiftCLI
import Rainbow

public class LogConsolePrinter: LogPrinter {

    // MARK: - Type Properties

    public static let shared = LogConsolePrinter()

    // MARK: - Initializers

    private init() { }

    // MARK: - LogPrinter

    public func print(success line: String) {
        Term.stdout <<< line.green
    }

    public func print(fail line: String) {
        Term.stderr <<< line.red
    }

    public func print(info line: String) {
        Term.stdout <<< line
    }
}
