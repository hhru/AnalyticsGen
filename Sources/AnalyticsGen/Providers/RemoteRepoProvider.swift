import Foundation

protocol RemoteRepoProvider {

    func fetchRepo(owner: String, repo: String, ref: GitReferenceType, token: String) async throws -> URL
}
