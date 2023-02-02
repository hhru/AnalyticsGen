import Foundation

extension Sequence {

    // MARK: - Instance Properties

    public var lazyFirst: Element? {
        first { _ in true }
    }

    // MARK: - Instance Methods

    public func mapFirst<R>(_ transform: (Element) throws -> R?) rethrows -> R? {
        for element in self {
            if let result = try transform(element) {
                return result
            }
        }

        return nil
    }
}
