import Foundation
import PathKit
import Yams

struct DefaultEventProvider: EventProvider {

    // MARK: - EventProvider

    func fetchEvent(from schemaURL: URL) throws -> Event {
        let schemaPath = Path(schemaURL.path)
        let schemaContent = try schemaPath.read(.utf8)

        return try YAMLDecoder().decode(from: schemaContent)
    }
}
