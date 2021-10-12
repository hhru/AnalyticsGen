import Foundation

public enum Log {

    // MARK: - Type Properties

    private static let dateFormatter = DateFormatter(dateFormat: .defaultDateFormat)

    // MARK: -

    public private(set) static var printers: [LogPrinter] = [LogConsolePrinter.shared]

    public static var dateFormat: String {
        get { Log.dateFormatter.dateFormat }
        set { Log.dateFormatter.dateFormat = newValue }
    }

    // MARK: - Type Methods

    @inline(__always)
    private static func line(
        layer: @autoclosure () -> String,
        text: @autoclosure () -> String,
        sender: @autoclosure () -> Any?,
        date: @autoclosure () -> Date
    ) -> String {
        let body = sender().map { "\(String(describing: type(of: $0))): \(text())" } ?? text()

        return "\(dateFormatter.string(from: date())) \(layer()) \(body)"
    }

    // MARK: -

    public static func registerPrinter(_ printer: LogPrinter) {
        if !printers.contains(where: { $0 === printer }) {
            printers.append(printer)
        }
    }

    public static func unregisterPrinter(_ printer: LogPrinter) {
        printers.removeAll { $0 === printer }
    }

    public static func success(
        _ text: @autoclosure () -> String,
        from sender: @autoclosure () -> Any? = nil,
        date: @autoclosure () -> Date = Date()
    ) {
        printers.forEach {
            $0.print(
                success: line(layer: .success, text: text(), sender: sender(), date: date())
            )
        }
    }

    public static func fail(
        _ text: @autoclosure () -> String,
        from sender: @autoclosure () -> Any? = nil,
        date: @autoclosure () -> Date = Date()
    ) {
        printers.forEach {
            $0.print(
                fail: line(layer: .fail, text: text(), sender: sender(), date: date())
            )
        }
    }

    public static func info(
        _ text: @autoclosure () -> String,
        from sender: @autoclosure () -> Any? = nil,
        date: @autoclosure () -> Date = Date()
    ) {
        printers.forEach {
            $0.print(
                info: line(layer: .info, text: text(), sender: sender(), date: date())
            )
        }
    }
}

// MARK: -

private extension String {

    // MARK: - Type Properties

    static let defaultDateFormat = "[HH:mm:ss.SSSS]"
    static let success = "[SUCCESS]"
    static let fail = "[FAIL]"
    static let info = "[INFO]"
}

// MARK: -

private extension DateFormatter {

    // MARK: - Initializers

    convenience init(dateFormat: String) {
        self.init()

        self.dateFormat = dateFormat
    }
}
