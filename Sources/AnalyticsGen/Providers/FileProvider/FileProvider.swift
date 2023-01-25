import PromiseKit

protocol FileProvider {

    // MARK: - Instance Methods

    func readFile<FileContent: Decodable>(at path: String) throws -> FileContent
    func readFile<FileContent: Decodable>(at path: String, type: FileContent.Type) throws -> FileContent

    func readFileIfExists<FileContent: Decodable>(at path: String) throws -> FileContent?
    func readFileIfExists<FileContent: Decodable>(at path: String, type: FileContent.Type) throws -> FileContent?

    func writeFile<FileContent: Encodable>(content: FileContent, at path: String) throws
}

extension FileProvider {

    // MARK: - Instance Methods

    func readFile<FileContent: Decodable>(at path: String, type: FileContent.Type) throws -> FileContent {
        try readFile(at: path)
    }

    func readFileIfExists<FileContent: Decodable>(at path: String, type: FileContent.Type) throws -> FileContent? {
        try readFileIfExists(at: path)
    }
}
