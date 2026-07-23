import Testing
import Foundation
import AnalyticsGenTools
@testable import AnalyticsGen

/// Тесты меняют текущую директорию процесса (`changeCurrentDirectoryPath`) — cwd глобален
/// для всего тестового процесса. `.serialized` сериализует только тесты этого сьюта;
/// другие сьюты, использующие относительные пути, будут несовместимы с параллельным запуском.
@Suite(.serialized)
final class GitTests {

    private let repoPath: String
    private let originPath: String
    private let previousDirectoryPath: String

    init() throws {
        previousDirectoryPath = FileManager.default.currentDirectoryPath
        repoPath = NSTemporaryDirectory() + "GitTests-" + UUID().uuidString
        originPath = repoPath + "-origin.git"

        try FileManager.default.createDirectory(atPath: repoPath, withIntermediateDirectories: true)
        FileManager.default.changeCurrentDirectoryPath(repoPath)

        try shell("git init")
        try shell("git config user.email test@example.com")
        try shell("git config user.name Test")
        try writeFile("README.md", "initial")
        try shell("git add . && git commit -m initial")
    }

    deinit {
        FileManager.default.changeCurrentDirectoryPath(previousDirectoryPath)
        try? FileManager.default.removeItem(atPath: repoPath)
        try? FileManager.default.removeItem(atPath: originPath)
    }

    /// Поднимает локальный bare-origin с веткой `develop` и отводит от неё фиче-ветку.
    private func makeOriginWithDevelopAndFeatureBranch() throws {
        try shell("git init --bare \"\(originPath)\"")
        try shell("git remote add origin \"\(originPath)\"")
        try shell("git branch -M develop")
        try shell("git push -q -u origin develop")
        try shell("git checkout -q -b feature")
    }

    private func writeFile(_ relativePath: String, _ content: String) throws {
        let url = URL(fileURLWithPath: repoPath).appendingPathComponent(relativePath)

        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try content.write(to: url, atomically: true, encoding: .utf8)
    }

    // MARK: - ensureGitRepository

    @Test
    func ensureGitRepositoryPassesInsideRepository() throws {
        try Git.ensureGitRepository()
    }

    @Test
    func ensureGitRepositoryThrowsOutsideRepository() throws {
        let nonRepoPath = NSTemporaryDirectory() + "GitTestsNonRepo-" + UUID().uuidString
        try FileManager.default.createDirectory(atPath: nonRepoPath, withIntermediateDirectories: true)

        defer {
            FileManager.default.changeCurrentDirectoryPath(repoPath)
            try? FileManager.default.removeItem(atPath: nonRepoPath)
        }

        FileManager.default.changeCurrentDirectoryPath(nonRepoPath)

        #expect(throws: MessageError.self) {
            try Git.ensureGitRepository()
        }
    }

    // MARK: - hasBranchCommits

    @Test
    func hasBranchCommitsReturnsTrueWhenBranchCommitTouchesPath() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try writeFile("Generated/Event.swift", "struct Event {}")
        try shell("git add . && git commit -m generated")

        #expect(try Git.hasBranchCommits(in: ["Generated"], baseBranch: "develop"))
    }

    @Test
    func hasBranchCommitsReturnsFalseWhenBranchCommitsOutsidePaths() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try writeFile("Docs/notes.md", "notes")
        try shell("git add . && git commit -m docs")

        #expect(try !Git.hasBranchCommits(in: ["Generated"], baseBranch: "develop"))
    }

    @Test
    func hasBranchCommitsReturnsFalseWhenNoCommitsAheadOfBase() throws {
        try makeOriginWithDevelopAndFeatureBranch()

        #expect(try !Git.hasBranchCommits(in: ["Generated"], baseBranch: "develop"))
    }

    @Test
    func hasBranchCommitsReturnsFalseForEmptyPaths() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try writeFile("Generated/Event.swift", "struct Event {}")
        try shell("git add . && git commit -m generated")

        #expect(try !Git.hasBranchCommits(in: [], baseBranch: "develop"))
    }

    // MARK: - currentBranch

    @Test
    func currentBranchReturnsBranchName() throws {
        try shell("git branch -M develop")

        #expect(try Git.currentBranch() == "develop")
    }

    @Test
    func currentBranchReturnsHEADWhenDetached() throws {
        try shell("git checkout -q --detach")

        #expect(try Git.currentBranch() == "HEAD")
    }

    // MARK: - changedPaths(in:)

    @Test
    func changedPathsDetectsUntrackedFilesInsideDestination() throws {
        try writeFile("Analytics/Event.swift", "event")

        let changed = try Git.changedPaths(in: ["Analytics"])

        #expect(changed == ["Analytics"])
    }

    @Test
    func changedPathsIgnoresChangesOutsideDestinations() throws {
        try writeFile("Feature.swift", "feature")

        let changed = try Git.changedPaths(in: ["Analytics"])

        #expect(changed.isEmpty)
    }

    @Test
    func changedPathsSkipsUnchangedAndMissingDestinations() throws {
        try writeFile("Analytics/Event.swift", "event")

        let changed = try Git.changedPaths(in: ["Analytics", "MissingDestination"])

        #expect(changed == ["Analytics"])
    }

    @Test
    func changedPathsDetectsDeletionsInsideDestination() throws {
        try writeFile("Analytics/Old.swift", "old")
        try shell("git add . && git commit -m seed")
        try FileManager.default.removeItem(atPath: repoPath + "/Analytics/Old.swift")

        let changed = try Git.changedPaths(in: ["Analytics"])

        #expect(changed == ["Analytics"])
    }

    @Test
    func changedPathsSupportsPathsWithSpaces() throws {
        try writeFile("My Analytics/Event.swift", "event")

        let changed = try Git.changedPaths(in: ["My Analytics"])

        #expect(changed == ["My Analytics"])
    }

    // MARK: - commitAndTag(message:tag:paths:)

    @Test
    func commitIncludesOnlyGivenPathsAndPreservesForeignIndex() throws {
        try writeFile("Feature.swift", "wip")
        try shell("git add Feature.swift")
        try writeFile("Untracked.txt", "untracked")
        try writeFile("Analytics/Event.swift", "event")

        try Git.commitAndTag(message: "analytics commit", tag: "analytics/test-1", paths: ["Analytics"])

        let committedFiles = try shell("git show --name-only --pretty=format: HEAD")
        #expect(committedFiles.contains("Analytics/Event.swift"))
        #expect(!committedFiles.contains("Feature.swift"))

        let status = try shell("git status --porcelain")
        #expect(status.contains("A  Feature.swift"))
        #expect(status.contains("?? Untracked.txt"))

        let tags = try shell("git tag -l")
        #expect(tags.contains("analytics/test-1"))
    }

    @Test
    func commitLeavesUnstagedModificationsOutsideDestinationUntouched() throws {
        try writeFile("Feature.swift", "original")
        try shell("git add . && git commit -m seed")
        try writeFile("Feature.swift", "modified")
        try writeFile("Analytics/Event.swift", "event")

        try Git.commitAndTag(message: "analytics commit", tag: "analytics/test-2", paths: ["Analytics"])

        let status = try shell("git status --porcelain")
        #expect(status.contains(" M Feature.swift"))
    }

    @Test
    func commitStagesDeletionsInsideDestination() throws {
        try writeFile("Analytics/Old.swift", "old")
        try shell("git add . && git commit -m seed")
        try FileManager.default.removeItem(atPath: repoPath + "/Analytics/Old.swift")
        try writeFile("Analytics/New.swift", "new")

        try Git.commitAndTag(message: "regen", tag: "analytics/test-3", paths: ["Analytics"])

        let committedTree = try shell("git ls-tree -r --name-only HEAD")
        #expect(!committedTree.contains("Analytics/Old.swift"))
        #expect(committedTree.contains("Analytics/New.swift"))
    }

    @Test
    func commitSupportsMultiplePathsIncludingSpaces() throws {
        try writeFile("Analytics/Event.swift", "event")
        try writeFile("My Analytics/Event.swift", "event")

        try Git.commitAndTag(
            message: "analytics commit",
            tag: "analytics/test-4",
            paths: ["Analytics", "My Analytics"]
        )

        let committedFiles = try shell("git show --name-only --pretty=format: HEAD")
        #expect(committedFiles.contains("Analytics/Event.swift"))
        #expect(committedFiles.contains("My Analytics/Event.swift"))
    }

    @Test
    func commitAndTagThrowsOnEmptyPaths() {
        #expect(throws: MessageError.self) {
            try Git.commitAndTag(message: "message", tag: "tag", paths: [])
        }
    }

    // MARK: - checkNoForeignAnalyticsTags(branch:baseBranch:)

    @Test
    func foreignTagCheckThrowsWhenRangeContainsForeignTag() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try shell("git commit --allow-empty -m generated")
        try shell("git tag analytics/Z-1")

        do {
            try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
            Issue.record("Expected MessageError, but no error was thrown")
        } catch let error as MessageError {
            #expect(error.message.contains("another branch: Z"))
            #expect(error.message.contains("--branch Z"))
        }
    }

    @Test
    func foreignTagCheckPassesWhenOnlyOwnTagsInRange() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try shell("git commit --allow-empty -m generated")
        try shell("git tag analytics/X-1")

        try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
    }

    @Test
    func foreignTagCheckPassesOnCleanBranch() throws {
        try makeOriginWithDevelopAndFeatureBranch()

        try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
    }

    @Test
    func foreignTagCheckIgnoresTagsReachableFromBase() throws {
        try shell("git tag analytics/OLD-1")
        try makeOriginWithDevelopAndFeatureBranch()

        try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
    }

    @Test
    func foreignTagCheckFetchesForeignTagFromOrigin() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try shell("git commit --allow-empty -m generated")
        try shell("git tag analytics/Z-1")
        try shell("git push -q origin feature analytics/Z-1")
        try shell("git tag -d analytics/Z-1")

        do {
            try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
            Issue.record("Expected MessageError, but no error was thrown")
        } catch let error as MessageError {
            #expect(error.message.contains("another branch: Z"))
        }
    }

    @Test
    func foreignTagCheckThrowsWithoutOrigin() {
        #expect(throws: (any Error).self) {
            try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
        }
    }

    @Test
    func foreignTagCheckListsAllForeignBranches() throws {
        try makeOriginWithDevelopAndFeatureBranch()
        try shell("git commit --allow-empty -m gen1 && git tag analytics/Z1-1")
        try shell("git commit --allow-empty -m gen2 && git tag analytics/Z2-1")

        do {
            try Git.checkNoForeignAnalyticsTags(branch: "X", baseBranch: "develop")
            Issue.record("Expected MessageError, but no error was thrown")
        } catch let error as MessageError {
            #expect(error.message.contains("Z1"))
            #expect(error.message.contains("Z2"))
        }
    }
}
