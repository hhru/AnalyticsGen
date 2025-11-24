import Foundation

extension Sequence {

    public var lazyFirst: Element? {
        first { _ in true }
    }

    public func mapFirst<R>(_ transform: (Element) throws -> R?) rethrows -> R? {
        for element in self {
            if let result = try transform(element) {
                return result
            }
        }

        return nil
    }
    
    public func concurrentForEach(
        _ operation: @escaping (Element) async throws -> Void
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask {
                    try await operation(element)
                }
            }
            
            try await group.waitForAll()
        }
    }
}
