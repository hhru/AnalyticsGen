import Foundation

public protocol LogPrinter: AnyObject {

    // MARK: - Instance Methods

    func print(success line: String)
    func print(fail line: String)
    func print(info line: String)
}
