import Foundation

extension Collection {

    // MARK: - Instance Properties

    public var nonEmpty: Self? {
        isEmpty ? nil : self
    }

    // MARK: - Instance Subscripts

    public subscript(safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
