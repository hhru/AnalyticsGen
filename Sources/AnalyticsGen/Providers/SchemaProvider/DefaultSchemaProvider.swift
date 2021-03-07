import Foundation
import PathKit
import Yams

struct DefaultSchemaProvider: SchemaProvider {

    // MARK: - SchemaProvider

    func fetchSchema(from schemaPath: String) throws -> Schema {
        let schemaPath = Path(schemaPath)
        let schemaContent = try schemaPath.read(.utf8)

        if let schema = try Yams.load(yaml: schemaContent) as? Schema {
            return schema
        } else {
            throw SpecificationProviderError(code: .invalidSpecification(path: schemaPath.string))
        }
    }
}
