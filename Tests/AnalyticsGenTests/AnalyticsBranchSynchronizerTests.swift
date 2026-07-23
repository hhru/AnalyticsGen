import Testing
import Foundation
import AnalyticsGenTools
@testable import AnalyticsGen

/// Интеграционные тесты на реальных git-репозиториях во временной директории:
/// bare-репозиторий выступает как origin, `seed` — клон для наполнения origin коммитами,
/// `work` — аналог временного клона аналитики, с которым работает синхронайзер.
@Suite(.serialized)
final class AnalyticsBranchSynchronizerTests {

    private let synchronizer = DefaultAnalyticsBranchSynchronizer()

    private let rootPath: String
    private let originPath: String
    private let seedPath: String
    private let workPath: String

    init() throws {
        rootPath = NSTemporaryDirectory() + "AnalyticsBranchSynchronizerTests-" + UUID().uuidString
        originPath = rootPath + "/origin.git"
        seedPath = rootPath + "/seed"
        workPath = rootPath + "/work"

        try FileManager.default.createDirectory(atPath: rootPath, withIntermediateDirectories: true)

        // Все команды с `cd`: глобальный cwd процесса меняет параллельно бегущий GitTests,
        // и к моменту запуска команды он может быть уже удалён (git падает с exit 128).
        try shell("cd \(rootPath) && git init --bare \(originPath)")
        try shell("cd \(rootPath) && git clone \(originPath) \(seedPath) 2>/dev/null")
        try configureGitUser(at: seedPath)

        try shell("cd \(seedPath) && git checkout -b develop-ios")
        try writeFile(seedPath + "/schema.yaml", "initial")
        try shell("cd \(seedPath) && git add . && git commit -m initial && git push -u origin develop-ios")
        try shell("cd \(seedPath) && git checkout -b feature-ios && git push -u origin feature-ios")
    }

    deinit {
        try? FileManager.default.removeItem(atPath: rootPath)
    }

    // MARK: - Helpers

    private func configureGitUser(at path: String) throws {
        try shell("cd \(path) && git config user.email test@example.com && git config user.name Test")
    }

    private func writeFile(_ absolutePath: String, _ content: String) throws {
        try content.write(toFile: absolutePath, atomically: true, encoding: .utf8)
    }

    private func makeWorkClone(branch: String) throws {
        try shell("cd \(rootPath) && git clone -b \(branch) \(originPath) \(workPath) 2>/dev/null")
        try configureGitUser(at: workPath)
    }

    private func commitToSeed(branch: String, file: String, content: String, message: String) throws {
        try shell("cd \(seedPath) && git checkout \(branch) 2>/dev/null")
        try writeFile(seedPath + "/" + file, content)
        try shell("cd \(seedPath) && git add . && git commit -m '\(message)' && git push origin \(branch)")
    }

    private func headSHA(at path: String, branch: String = "HEAD") throws -> String {
        try shell("cd \(path) && git rev-parse \(branch)").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func mergeCommitCount(at path: String, branch: String) throws -> Int {
        let output = try shell("cd \(path) && git rev-list --count --merges \(branch)")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let count = Int(output) else {
            throw MessageError("Unexpected rev-list output: \(output)")
        }

        return count
    }

    // MARK: - sync

    @Test
    func syncIsNoOpWhenCurrentBranchEqualsBaseBranch() throws {
        try makeWorkClone(branch: "develop-ios")
        try commitToSeed(branch: "develop-ios", file: "schema.yaml", content: "updated", message: "update")

        let shaBefore = try headSHA(at: workPath)

        try synchronizer.sync(
            repoPath: workPath,
            currentBranch: "develop-ios",
            baseBranch: "develop-ios"
        )

        #expect(try headSHA(at: workPath) == shaBefore)
    }

    @Test
    func syncDoesNothingWhenBranchUpToDate() throws {
        try makeWorkClone(branch: "feature-ios")

        let originSHABefore = try headSHA(at: originPath, branch: "feature-ios")

        try synchronizer.sync(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        #expect(try headSHA(at: originPath, branch: "feature-ios") == originSHABefore)
        #expect(try mergeCommitCount(at: workPath, branch: "feature-ios") == 0)
    }

    @Test
    func syncMergesAndPushesWhenBranchesDiverged() throws {
        try commitToSeed(branch: "feature-ios", file: "feature.yaml", content: "feature", message: "feature update")
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "base.yaml", content: "base change", message: "base update")

        try synchronizer.sync(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        #expect(try mergeCommitCount(at: originPath, branch: "feature-ios") == 1)

        // develop-ios стал предком feature-ios в origin — merge реально дошёл до remote.
        try shell("cd \(originPath) && git merge-base --is-ancestor develop-ios feature-ios")
    }

    @Test
    func syncFastForwardsAndPushesWhenBranchStrictlyBehind() throws {
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "base.yaml", content: "base change", message: "base update")

        try synchronizer.sync(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        // Ветка без собственных коммитов — git делает fast-forward, лишнего merge-коммита нет.
        #expect(try mergeCommitCount(at: originPath, branch: "feature-ios") == 0)
        #expect(try headSHA(at: originPath, branch: "feature-ios") == headSHA(at: originPath, branch: "develop-ios"))
    }

    @Test
    func syncAbortsAndThrowsOnMergeConflict() throws {
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "schema.yaml", content: "base version", message: "base update")

        try writeFile(workPath + "/schema.yaml", "feature version")
        try shell("cd \(workPath) && git add . && git commit -m conflicting")

        let originSHABefore = try headSHA(at: originPath, branch: "feature-ios")

        #expect(throws: MessageError.self) {
            try synchronizer.sync(
                repoPath: workPath,
                currentBranch: "feature-ios",
                baseBranch: "develop-ios"
            )
        }

        // merge --abort вернул рабочее дерево в чистое состояние, merge не в процессе.
        let status = try shell("cd \(workPath) && git status --porcelain")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(status.isEmpty)
        #expect(throws: (any Error).self) {
            try shell("cd \(workPath) && git rev-parse -q --verify MERGE_HEAD")
        }

        // В origin ничего не уехало.
        #expect(try headSHA(at: originPath, branch: "feature-ios") == originSHABefore)
    }

    @Test
    func syncThrowsWhenPushRejected() throws {
        try makeWorkClone(branch: "feature-ios")

        // origin/feature-ios уезжает вперёд после того, как work-клон создан → push будет non-fast-forward.
        try commitToSeed(branch: "feature-ios", file: "other.yaml", content: "parallel", message: "parallel update")
        try commitToSeed(branch: "develop-ios", file: "base.yaml", content: "base change", message: "base update")

        do {
            try synchronizer.sync(
                repoPath: workPath,
                currentBranch: "feature-ios",
                baseBranch: "develop-ios"
            )
            Issue.record("Expected sync to throw on rejected push")
        } catch let error as MessageError {
            #expect(error.message.contains("push failed"))
        }
    }

    // MARK: - isBranchBehind

    @Test
    func isBranchBehindReturnsTrueWhenBehind() throws {
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "base.yaml", content: "base change", message: "base update")

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        #expect(isBehind)
    }

    @Test
    func isBranchBehindReturnsFalseWhenUpToDate() throws {
        try makeWorkClone(branch: "feature-ios")

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        #expect(!isBehind)
    }

    @Test
    func isBranchBehindReturnsFalseWhenAhead() throws {
        try makeWorkClone(branch: "feature-ios")
        try writeFile(workPath + "/ahead.yaml", "ahead")
        try shell("cd \(workPath) && git add . && git commit -m ahead")

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        #expect(!isBehind)
    }

    @Test
    func isBranchBehindUsesHEADWhenCurrentBranchIsNil() throws {
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "base.yaml", content: "base change", message: "base update")

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: nil,
            baseBranch: "develop-ios"
        )

        #expect(isBehind)
    }

    // MARK: - isBranchBehind с pathspec

    @Test
    func isBranchBehindWithPathsReturnsTrueWhenBaseCommitTouchesPath() throws {
        try makeWorkClone(branch: "feature-ios")
        try FileManager.default.createDirectory(atPath: seedPath + "/Generated", withIntermediateDirectories: true)
        try commitToSeed(branch: "develop-ios", file: "Generated/gen.yaml", content: "generated", message: "regen")

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios",
            paths: ["Generated"]
        )

        #expect(isBehind)
    }

    @Test
    func isBranchBehindWithPathsReturnsFalseWhenBaseCommitsOutsidePath() throws {
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "other.yaml", content: "other", message: "outside update")

        let isBehindFiltered = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios",
            paths: ["Generated"]
        )
        let isBehindUnfiltered = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios"
        )

        // Тот же стейт: без фильтра ветка отстаёт, но фильтр по нетронутому пути отсекает.
        #expect(!isBehindFiltered)
        #expect(isBehindUnfiltered)
    }

    @Test
    func isBranchBehindWithEmptyPathsBehavesLikeUnfiltered() throws {
        try makeWorkClone(branch: "feature-ios")
        try commitToSeed(branch: "develop-ios", file: "other.yaml", content: "other", message: "outside update")

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios",
            paths: []
        )

        #expect(isBehind)
    }

    @Test
    func isBranchBehindWithPathsDetectsFileMovedIntoPath() throws {
        try makeWorkClone(branch: "feature-ios")
        try shell(
            """
            cd \(seedPath) && git checkout develop-ios 2>/dev/null && mkdir -p Generated \
            && git mv schema.yaml Generated/schema.yaml && git commit -m 'move in' && git push origin develop-ios
            """
        )

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios",
            paths: ["Generated"]
        )

        #expect(isBehind)
    }

    @Test
    func isBranchBehindWithPathsDetectsFileMovedOutOfPath() throws {
        try FileManager.default.createDirectory(atPath: seedPath + "/Generated", withIntermediateDirectories: true)
        try commitToSeed(branch: "develop-ios", file: "Generated/gen.yaml", content: "generated", message: "regen")
        try shell("cd \(seedPath) && git checkout develop-ios 2>/dev/null && git push origin develop-ios:feature-ios -f")
        try makeWorkClone(branch: "feature-ios")
        try shell(
            """
            cd \(seedPath) && git mv Generated/gen.yaml gen.yaml \
            && git commit -m 'move out' && git push origin develop-ios
            """
        )

        let isBehind = try synchronizer.isBranchBehind(
            repoPath: workPath,
            currentBranch: "feature-ios",
            baseBranch: "develop-ios",
            paths: ["Generated"]
        )

        #expect(isBehind)
    }
}
