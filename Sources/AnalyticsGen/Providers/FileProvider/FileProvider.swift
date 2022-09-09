import PromiseKit

protocol FileProvider {

    // MARK: - Instance Methods

    func readFile<FileContent: Decodable>(at path: String) throws -> FileContent
    func readFile<FileContent: Decodable>(at path: String) -> Promise<FileContent>
    func readFile<FileContent: Decodable>(at path: String, type: FileContent.Type) -> Promise<FileContent>

    func readFileIfExists<FileContent: Decodable>(at path: String) throws -> FileContent?
    func readFileIfExists<FileContent: Decodable>(at path: String) -> Promise<FileContent?>
    func readFileIfExists<FileContent: Decodable>(at path: String, type: FileContent.Type) -> Promise<FileContent?>

    func writeFile<FileContent: Encodable>(content: FileContent, at path: String) throws
}

// MARK: -

extension FileProvider {

    // MARK: - Instance Methods

    func readFile<FileContent: Decodable>(at path: String) -> Promise<FileContent> {
        Promise { seal in
            seal.fulfill(try readFile(at: path))
        }
    }
    
    func readFile<FileContent: Decodable>(at path: String, type: FileContent.Type) -> Promise<FileContent> {
        readFile(at: path)
    }

    func readFileIfExists<FileContent: Decodable>(at path: String) -> Promise<FileContent?> {
        Promise { seal in
            seal.fulfill(try readFileIfExists(at: path))
        }
    }
    
    func readFileIfExists<FileContent: Decodable>(at path: String, type: FileContent.Type) -> Promise<FileContent?> {
        readFileIfExists(at: path)
    }
}
