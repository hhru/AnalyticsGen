import Foundation

extension DefaultStringInterpolation {

    // MARK: - Instance Methods

    public mutating func appendInterpolation<T>(optional: T?) {
        switch optional {
        case .none:
            appendInterpolation("nil")

        case .some(let wrapped):
            appendInterpolation(wrapped)
        }
    }
}
