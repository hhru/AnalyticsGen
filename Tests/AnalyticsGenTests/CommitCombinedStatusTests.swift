import Testing
import Foundation
@testable import AnalyticsGen

struct CommitCombinedStatusTests {

    @Test
    func decodesSuccessPayload() throws {
        let json = Data("""
        {
            "state": "success",
            "total_count": 1,
            "statuses": [
                {
                    "status": "success",
                    "context": "Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios"
                }
            ]
        }
        """.utf8)

        let combined = try JSONDecoder().decode(CommitCombinedStatus.self, from: json)

        #expect(combined.state == .success)
        #expect(combined.totalCount == 1)
        #expect(combined.statuses.count == 1)
        #expect(combined.statuses[0].state == .success)
        #expect(combined.statuses[0].context == "Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios")
    }

    @Test
    func decodesFailurePayloadWithStatusKeyInElements() throws {
        // У элементов statuses статус приходит в ключе "status", не "state".
        let json = Data("""
        {
            "state": "failure",
            "total_count": 2,
            "statuses": [
                { "status": "failure", "context": "check-a" },
                { "status": "pending", "context": "check-b" }
            ]
        }
        """.utf8)

        let combined = try JSONDecoder().decode(CommitCombinedStatus.self, from: json)

        #expect(combined.state == .failure)
        #expect(combined.statuses[0].state == .failure)
        #expect(combined.statuses[1].state == .pending)
    }

    @Test
    func decodesEmptyStateAsUnknownWhenNoChecks() throws {
        // total_count == 0: Forgejo отдаёт state "" (пустую строку, не "pending").
        let json = Data("""
        {
            "state": "",
            "total_count": 0,
            "statuses": []
        }
        """.utf8)

        let combined = try JSONDecoder().decode(CommitCombinedStatus.self, from: json)

        #expect(combined.state == .unknown)
        #expect(!combined.state.isBlocking)
    }

    @Test
    func blockingStates() {
        #expect(CommitCombinedStatus.State.error.isBlocking)
        #expect(CommitCombinedStatus.State.failure.isBlocking)
        #expect(CommitCombinedStatus.State.warning.isBlocking)
        #expect(!CommitCombinedStatus.State.pending.isBlocking)
        #expect(!CommitCombinedStatus.State.success.isBlocking)
        #expect(!CommitCombinedStatus.State.unknown.isBlocking)
    }
}
