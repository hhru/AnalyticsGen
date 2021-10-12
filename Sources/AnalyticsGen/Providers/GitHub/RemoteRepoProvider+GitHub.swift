import Foundation
import PromiseKit
import AnalyticsGenTools
import KeychainAccess

extension RemoteRepoProvider {

    // MARK: - Instance Methods

    func fetchRepo(gitHubConfiguration configuration: GitHubSourceConfiguration) -> Promise<URL> {
        Promise { seal in
            fetchRepo(
                owner: configuration.owner,
                repo: configuration.repo,
                ref: configuration.ref.name,
                token: try configuration.accessToken.resolveToken()
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
        switch self {
        case .value(let token):
            return token

        case .environmentVariable(let environmentVariable):
            guard let token = ProcessInfo.processInfo.environment[environmentVariable] else {
                throw MessageError("Environment variable '\(environmentVariable)' not found.")
            }

            return token

        case .keychain(let parameters):
            let keychain = Keychain(service: parameters.service)

            guard let token = try keychain.getString(parameters.key) else {
                throw MessageError("Failed to obtain token from keychain")
            }

            return token
        }
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
        }
    }
}
