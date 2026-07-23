import Foundation

struct RemoteRepoSourceConfiguration: Decodable, Equatable {

    let owner: String
    let repo: String
    let defaultBranch: String
    let branchSuffix: String
    let accessToken: AccessTokenConfiguration
}
