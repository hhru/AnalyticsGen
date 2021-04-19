import Foundation

protocol EventProvider {

    // MARK: - Instance Methods

    func fetchEvent(from schemaURL: URL) throws -> Event
}
