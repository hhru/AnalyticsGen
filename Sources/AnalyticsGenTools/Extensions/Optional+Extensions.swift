import Foundation

extension Optional {

    // MARK: - Instance Properties

    public var isNil: Bool {
        self == nil
    }

    public func throwing() throws -> Wrapped {
        if let wrapped = self {
            return wrapped
        } else {
            throw MessageError("Failed to unwrap optional value.")
        }
    }
}

extension Optional where Wrapped: Collection {

    // MARK: - Instance Properties

    public var isEmptyOrNil: Bool {
        self?.isEmpty ?? true
    }
}
