import Foundation
import PromiseKit

protocol RemoteRepoProvider {

    // MARK: - Instance Methods

    func fetchRepo(owner: String, repo: String, ref: String, username: String, token: String) -> Promise<URL>
}
