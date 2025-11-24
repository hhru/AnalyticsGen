import Foundation
import Rainbow

public class LogConsolePrinter: LogPrinter {

    public static let shared = LogConsolePrinter()

    private init() { }

    public func print(success line: String) {
        Swift.print(line.green)
    }

    public func print(fail line: String) {
        Swift.print(line.red)
    }

    public func print(info line: String) {
        Swift.print(line)
    }
}
