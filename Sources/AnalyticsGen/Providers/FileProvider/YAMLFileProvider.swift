import Yams
import PromiseKit
import PathKit

struct YAMLFileProvider: FileProvider {

    // MARK: - Instance Properties

    private let decoder = YAMLDecoder()
    private let encoder = YAMLEncoder()

    // MARK: - YAMLProvider

    func readFile<FileContent: Decodable>(at path: String) throws -> FileContent {
        let path = Path(path)
        let content = try path.read(.utf8)

        return try decoder.decode(from: content)
    }

    func readFileIfExists<FileContent: Decodable>(at path: String) throws -> FileContent? {
        let path = Path(path)

        guard path.exists else {
            return nil
        }

        return try decoder.decode(from: path.read(.utf8))
    }

    func writeFile<FileContent: Encodable>(content: FileContent, at path: String) throws {
        let path = Path(path)
        let content = try encoder.encode(content)

        try path.write(content, encoding: .utf8)
    }
}
