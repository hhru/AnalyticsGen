import Foundation
import PromiseKit
import AnalyticsGenTools
import KeychainAccess

extension RemoteRepoProvider {

    // MARK: - Instance Methods

    func fetchRepo(gitHubConfiguration configuration: GitHubSourceConfiguration, key: String) -> Promise<URL> {
        Promise { seal in
            fetchRepo(
                owner: configuration.owner,
                repo: configuration.repo,
                ref: configuration.ref.name,
                token: try configuration.accessToken.resolveToken(),
                key: key
            ).pipe(to: seal.resolve(_:))
        }
    }

    func fetchReference(gitHubConfiguration configuration: GitHubSourceConfiguration) -> Promise<GitReference> {
        Promise { seal in
            fetchReference(
                owner: configuration.owner,
                repo: configuration.repo,
                ref: configuration.ref.formatted,
                token: try configuration.accessToken.resolveToken()
            ).pipe(to: seal.resolve(_:))
        }
    }
}

// MARK: -

private extension AccessTokenConfiguration {

    // MARK: - Instance Methods

    func resolveToken() throws -> String {
        if let value = value {
            return value
        } else if let environmentVariable = environmentVariable,
                  let token = ProcessInfo.processInfo.environment[environmentVariable] {
            return token
        } else if let parameters = keychainParameters {
            let keychain = Keychain(service: parameters.service)

            if let token = try keychain.getString(parameters.key) {
                return token
            }
        }

        throw MessageError("GitHub access token not found.")
    }
}

// MARK: -

private extension GitHubReferenceConfiguration {

    // MARK: - Instance Properties

    var formatted: String {
        switch self {
        case .tag(let name):
            return "tags/\(name)"

        case .branch(let name):
            return "heads/\(name)"

        case .finders:
            fatalError("Логика резолва в следующей задаче")
        }
    }
}
