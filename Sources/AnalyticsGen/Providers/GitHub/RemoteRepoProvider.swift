import Foundation
import PromiseKit

protocol RemoteRepoProvider {

    // MARK: - Instance Methods

    func fetchRepo(owner: String, repo: String, ref: String, token: String, key: String) -> Promise<URL>
    func fetchReference(owner: String, repo: String, ref: String, token: String) -> Promise<GitReference>
}
