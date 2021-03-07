import Foundation

protocol SchemaProvider {

    // MARK: - Instance Methods

    func fetchSchema(from schemaPath: String) throws -> Schema
}
