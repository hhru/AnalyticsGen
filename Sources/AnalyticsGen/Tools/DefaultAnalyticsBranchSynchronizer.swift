import AnalyticsGenTools
import Foundation

struct DefaultAnalyticsBranchSynchronizer: AnalyticsBranchSynchronizer {

    func isBranchBehind(
        repoPath: String,
        currentBranch: String?,
        baseBranch: String,
        paths: [String]
    ) throws -> Bool {
        try shell("cd \(repoPath) && git fetch origin \(baseBranch)")

        let branch: String

        if let currentBranch = currentBranch {
            branch = currentBranch
        } else {
            branch = try shell("cd \(repoPath) && git rev-parse --abbrev-ref HEAD")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let pathspec = paths.isEmpty
            ? ""
            : " -- " + paths.map { "\"\($0)\"" }.joined(separator: " ")

        let output = try shell("cd \(repoPath) && git rev-list --count \(branch)..origin/\(baseBranch)\(pathspec)")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let commitsBehind = Int(output), commitsBehind > 0 {
            Log.debug("Branch '\(branch)' is behind 'origin/\(baseBranch)' by \(commitsBehind) commit(s)")
            return true
        }

        return false
    }

    func sync(
        repoPath: String,
        currentBranch: String,
        baseBranch: String
    ) throws {
        guard currentBranch != baseBranch else {
            return
        }

        guard try isBranchBehind(repoPath: repoPath, currentBranch: currentBranch, baseBranch: baseBranch) else {
            Log.debug("Analytics branch already up to date with \(baseBranch)")
            return
        }

        Log.info("Analytics branch '\(currentBranch)' is behind '\(baseBranch)', merging 'origin/\(baseBranch)'...")

        do {
            try shell("cd \(repoPath) && git merge --no-edit origin/\(baseBranch)")
        } catch {
            do {
                try shell("cd \(repoPath) && git merge --abort")
            } catch {
                Log.debug("git merge --abort failed: \(error.localizedDescription)")
            }

            throw MessageError(
                """
                ❌ Auto-merge 'origin/\(baseBranch)' into '\(currentBranch)' failed.
                \(error.localizedDescription)
                If there are merge conflicts, resolve them manually in the analytics repository and retry.
                """
            )
        }

        do {
            try shell("cd \(repoPath) && git push origin \(currentBranch)")
        } catch {
            throw MessageError(
                """
                ❌ Auto-merge succeeded locally but push failed: \(error.localizedDescription)
                If the branch is protected or was updated concurrently, retry the generator or push manually.
                """
            )
        }

        Log.info("Synced \(currentBranch) with \(baseBranch) ✓")
    }
}
