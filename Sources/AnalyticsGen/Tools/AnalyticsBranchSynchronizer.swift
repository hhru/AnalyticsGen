import Foundation

/// Синхронизация ветки аналитики с базовой веткой во временном клоне репозитория аналитики.
/// В отличие от `Git`, работает не с текущей директорией, а с явно переданным `repoPath`.
protocol AnalyticsBranchSynchronizer {

    func isBranchBehind(repoPath: String, currentBranch: String?, baseBranch: String, paths: [String]) throws -> Bool
    func sync(repoPath: String, currentBranch: String, baseBranch: String) throws
}

extension AnalyticsBranchSynchronizer {

    func isBranchBehind(repoPath: String, currentBranch: String?, baseBranch: String) throws -> Bool {
        try isBranchBehind(repoPath: repoPath, currentBranch: currentBranch, baseBranch: baseBranch, paths: [])
    }
}
