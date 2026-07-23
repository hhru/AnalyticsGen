import Testing
import Foundation
import AnalyticsGenTools
@testable import AnalyticsGen

struct AutogenPullRequestOpenerTests {

    private func makePR(
        number: Int,
        title: String,
        head: String,
        base: String,
        headLabel: String? = nil,
        state: PullRequestInfo.State = .open,
        merged: Bool? = false,
        mergeable: Bool? = true,
        headSha: String? = "abc123"
    ) -> PullRequestInfo {
        PullRequestInfo(
            number: number,
            title: title,
            state: state,
            merged: merged,
            mergeable: mergeable,
            head: .init(ref: head, label: headLabel ?? head, sha: headSha),
            base: .init(ref: base, label: base, sha: nil),
            htmlURL: URL(string: "https://forgejo.pyn.ru/hhru/hh-mobile-analytics/pulls/\(number)")!
        )
    }

    private func makeOpener(
        _ mock: MockForgejoPullRequestService,
        pollMaxAttempts: Int = 3
    ) -> AutogenPullRequestOpener {
        AutogenPullRequestOpener(service: mock, pollInterval: 0, pollMaxAttempts: pollMaxAttempts)
    }

    @discardableResult
    private func ensure(_ mock: MockForgejoPullRequestService) async throws -> Int {
        try await makeOpener(mock).ensurePullRequest(
            owner: "hhru",
            repo: "hh-mobile-analytics",
            analystBranch: "AN-123",
            platformBranch: "AN-123-ios",
            baseBranch: "develop-ios"
        )
    }

    private func autoMerge(_ mock: MockForgejoPullRequestService, pollMaxAttempts: Int = 3) async throws {
        try await makeOpener(mock, pollMaxAttempts: pollMaxAttempts).autoMergeAutogenPullRequest(
            owner: "hhru",
            repo: "hh-mobile-analytics",
            number: 10
        )
    }

    private func status(
        _ state: CommitCombinedStatus.State,
        contexts: [String] = []
    ) -> CommitCombinedStatus {
        CommitCombinedStatus(
            state: state,
            totalCount: contexts.count,
            statuses: contexts.map { .init(state: state, context: $0) }
        )
    }

    @Test
    func skipsWhenAutogenPRExistsAndReturnsItsNumber() async throws {
        let mock = MockForgejoPullRequestService()
        mock.findResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios")]

        let number = try await ensure(mock)

        #expect(number == 10)
        #expect(mock.createCalls.isEmpty)
        #expect(mock.findCalls.count == 1)
        #expect(mock.findCalls[0].head == "AN-123-ios")
    }

    @Test
    func throwsWhenAnalystPRNotFound() async {
        let mock = MockForgejoPullRequestService()
        mock.findResults = [nil]   // autogen-PR нет
        mock.analystResult = nil   // analyst-PR нет (ни открытого, ни merged)

        await #expect(throws: MessageError.self) {
            try await ensure(mock)
        }

        #expect(mock.createCalls.isEmpty)
    }

    @Test
    func createsPRWithCorrectFields() async throws {
        let mock = MockForgejoPullRequestService()
        mock.findResults = [nil] // autogen-PR ещё нет
        mock.analystResult = makePR(number: 55, title: "AN-123 Событие показа", head: "AN-123", base: "master")

        let number = try await ensure(mock)

        #expect(number == mock.createResult)
        #expect(mock.analystBranchCalls == ["AN-123"])
        #expect(mock.createCalls.count == 1)
        let call = try #require(mock.createCalls.first)
        #expect(call.owner == "hhru")
        #expect(call.repo == "hh-mobile-analytics")
        #expect(call.head == "AN-123-ios")
        #expect(call.base == "develop-ios")
        #expect(call.title == "[Autogen][iOS] AN-123 Событие показа")
        #expect(call.labels == [4786])
        #expect(call.body.contains("https://forgejo.pyn.ru/hhru/hh-mobile-analytics/pulls/55"))
        #expect(call.body.contains("iOS"))
        #expect(call.body.contains("AN-123"))
    }

    @Test
    func createsPRForMergedAnalystPR() async throws {
        let mock = MockForgejoPullRequestService()
        mock.findResults = [nil] // autogen-PR ещё нет
        // Смерженный analyst-PR: ветка удалена, head.ref стал refs/pull/55/head,
        // но head.label сохранил имя ветки.
        mock.analystResult = makePR(
            number: 55,
            title: "AN-123 Событие показа",
            head: "refs/pull/55/head",
            base: "master",
            headLabel: "AN-123",
            state: .closed,
            merged: true
        )

        try await ensure(mock)

        #expect(mock.createCalls.count == 1)
        let call = try #require(mock.createCalls.first)
        #expect(call.head == "AN-123-ios")
        #expect(call.base == "develop-ios")
        #expect(call.title == "[Autogen][iOS] AN-123 Событие показа")
    }

    // MARK: - autoMergeAutogenPullRequest

    @Test
    func autoMergeSchedulesAndSucceedsWhenMergedOnFirstPoll() async throws {
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios", state: .closed, merged: true)]

        try await autoMerge(mock)

        #expect(mock.scheduleMergeCalls.count == 1)
        let call = try #require(mock.scheduleMergeCalls.first)
        #expect(call.number == 10)
        #expect(call.method == "merge")
        #expect(call.deleteBranchAfterMerge == true)
        #expect(mock.getPullCalls == [10])
    }

    @Test
    func autoMergeWaitsForPendingChecksAndSucceedsWhenMerged() async throws {
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [
            makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios"),
            makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios", state: .closed, merged: true)
        ]
        mock.statusResults = [status(.pending, contexts: ["Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios"])]

        try await autoMerge(mock)

        #expect(mock.getPullCalls.count == 2)
        #expect(mock.statusCalls == ["abc123"])
    }

    @Test
    func autoMergeFailsWhenPRClosedWithoutMerge() async {
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios", state: .closed, merged: false)]

        await #expect(throws: MessageError.self) {
            try await autoMerge(mock)
        }
    }

    @Test
    func autoMergeFailsOnMergeConflict() async {
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios", mergeable: false)]

        await #expect(throws: MessageError.self) {
            try await autoMerge(mock)
        }

        #expect(mock.statusCalls.isEmpty)
    }

    @Test
    func autoMergeFailsOnFailingChecksWithCheckNamesAndLink() async {
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios")]
        mock.statusResults = [status(.failure, contexts: ["Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios"])]

        do {
            try await autoMerge(mock)
            Issue.record("Expected MessageError for failing checks")
        } catch let error as MessageError {
            #expect(error.message.contains("Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios"))
            #expect(error.message.contains("https://forgejo.pyn.ru/hhru/hh-mobile-analytics/pulls/10"))
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }

        #expect(mock.getPullCalls.count == 1)
    }

    @Test
    func autoMergeFailsOnTimeoutWhileChecksStillPending() async {
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios")]
        mock.statusResults = [status(.pending, contexts: ["Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios"])]

        await #expect(throws: MessageError.self) {
            try await autoMerge(mock, pollMaxAttempts: 3)
        }

        #expect(mock.getPullCalls.count == 3)
    }

    @Test
    func autoMergeTreatsAlreadyScheduledAsNonFatal() async throws {
        let mock = MockForgejoPullRequestService()
        mock.scheduleMergeError = ForgejoMergeError.rejected(
            code: 409,
            body: "pull request is already scheduled to auto merge when checks succeed [pull_id: 10]"
        )
        mock.pullResults = [makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios", state: .closed, merged: true)]

        try await autoMerge(mock)

        #expect(mock.getPullCalls == [10])
    }

    @Test
    func autoMergeFailsOnOtherMergeRejection() async {
        let mock = MockForgejoPullRequestService()
        mock.scheduleMergeError = ForgejoMergeError.rejected(
            code: 405,
            body: "not allowed to merge [reason: Not all required status checks successful]"
        )

        await #expect(throws: ForgejoMergeError.self) {
            try await autoMerge(mock)
        }

        #expect(mock.getPullCalls.isEmpty)
    }

    @Test
    func autoMergeWaitsWhenNoChecksReportedYet() async throws {
        // total_count == 0: Forgejo отдаёт state "" → .unknown, не blocking — ждём, не падаем.
        let mock = MockForgejoPullRequestService()
        mock.pullResults = [
            makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios"),
            makePR(number: 10, title: "x", head: "AN-123-ios", base: "develop-ios", state: .closed, merged: true)
        ]
        mock.statusResults = [status(.unknown)]

        try await autoMerge(mock)

        #expect(mock.getPullCalls.count == 2)
    }
}
