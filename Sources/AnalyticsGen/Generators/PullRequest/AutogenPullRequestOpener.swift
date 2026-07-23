import Foundation
import AnalyticsGenTools

/// Открывает (или находит) iOS Autogen-PR `<platformBranch> → <baseBranch>` в Forgejo
/// и умеет вливать его auto-merge'ем, когда генерация не дала iOS-изменений.
struct AutogenPullRequestOpener {

    private enum Constants {
        static let autogenLabelID = 4786
        static let platformLabel = "iOS"
        static let mergeMethod = "merge"
    }

    private let service: ForgejoPullRequestService
    private let pollInterval: TimeInterval
    private let pollMaxAttempts: Int

    /// - Parameters:
    ///   - service: Клиент Forgejo API.
    ///   - pollInterval: Пауза между опросами состояния PR после планирования auto-merge.
    ///   - pollMaxAttempts: Число опросов до таймаута. Дефолт ~5 минут:
    ///     CheckPRToMobileAnalytics идёт ~50с + запас на очередь агентов и webhook-задержку.
    init(
        service: ForgejoPullRequestService,
        pollInterval: TimeInterval = 15,
        pollMaxAttempts: Int = 20
    ) {
        self.service = service
        self.pollInterval = pollInterval
        self.pollMaxAttempts = pollMaxAttempts
    }

    /// Находит открытый или создаёт новый Autogen-PR.
    /// - Returns: Номер найденного/созданного PR.
    func ensurePullRequest(
        owner: String,
        repo: String,
        analystBranch: String,
        platformBranch: String,
        baseBranch: String
    ) async throws -> Int {
        if let existing = try await service.findPullRequest(
            owner: owner, repo: repo, head: platformBranch, base: baseBranch, state: "open"
        ) {
            Log.info("iOS Autogen-PR already exists: #\(existing.number) (\(platformBranch) → \(baseBranch)), skipping creation")
            return existing.number
        }

        guard let analystPR = try await service.findAnalystPullRequest(
            owner: owner, repo: repo, branch: analystBranch
        ) else {
            throw MessageError(
                "Analyst PR not found (neither open nor merged) for branch '\(analystBranch)' in \(owner)/\(repo). iOS Autogen-PR was not created."
            )
        }

        let title = "[Autogen][\(Constants.platformLabel)] \(analystPR.title)"
        let body = """
        Автоматически созданный PR для платформы \(Constants.platformLabel) из ветки аналитики \(analystBranch)

        Исходный PR: \(analystPR.htmlURL.absoluteString)
        """

        let number = try await service.createPullRequest(
            owner: owner,
            repo: repo,
            head: platformBranch,
            base: baseBranch,
            title: title,
            body: body,
            labels: [Constants.autogenLabelID]
        )

        Log.success("iOS Autogen-PR created: #\(number) (\(platformBranch) → \(baseBranch))")

        return number
    }

    /// Планирует auto-merge iOS Autogen-PR (Forgejo вольёт его, как только чеки станут зелёными,
    /// либо сразу, если уже зелёные) и поллит исход: merged — успех; закрытие без merge,
    /// merge-конфликт, красный чек или таймаут — ошибка.
    func autoMergeAutogenPullRequest(owner: String, repo: String, number: Int) async throws {
        do {
            try await service.scheduleMerge(
                owner: owner,
                repo: repo,
                number: number,
                method: Constants.mergeMethod,
                deleteBranchAfterMerge: true
            )
            Log.info("iOS Autogen-PR #\(number): auto-merge scheduled (merge_when_checks_succeed)")
        } catch let ForgejoMergeError.rejected(code, body) where code == 409 && Self.isAlreadyScheduled(body) {
            Log.info("iOS Autogen-PR #\(number): auto-merge already scheduled, polling outcome")
        }

        for attempt in 1...pollMaxAttempts {
            let pull = try await service.getPullRequest(owner: owner, repo: repo, number: number)

            if pull.merged == true {
                Log.success("iOS Autogen-PR #\(number) merged (no iOS changes generated)")
                return
            }

            if pull.state == .closed {
                throw MessageError("iOS Autogen-PR #\(number) was closed without merge: \(pull.htmlURL.absoluteString)")
            }

            if pull.mergeable == false {
                throw MessageError(
                    "iOS Autogen-PR #\(number) has merge conflicts — auto-merge will never run: \(pull.htmlURL.absoluteString). Resolve the conflict and merge manually."
                )
            }

            if let sha = pull.head.sha {
                let status = try await service.getCommitStatus(owner: owner, repo: repo, ref: sha)

                if status.state.isBlocking {
                    let failedChecks = status.statuses.filter { $0.state.isBlocking }.map(\.context)
                    throw MessageError(
                        "iOS Autogen-PR #\(number) has failing checks (\(failedChecks.joined(separator: ", "))) — auto-merge will never run: \(pull.htmlURL.absoluteString). Fix the checks and merge manually."
                    )
                }
            }

            if attempt < pollMaxAttempts {
                try await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
                continue
            }

            throw MessageError(
                "iOS Autogen-PR #\(number): not merged after ~\(Int(pollInterval) * (pollMaxAttempts - 1))s (checks still running). Auto-merge stays scheduled but the merge is not confirmed — please check the PR and merge it manually: \(pull.htmlURL.absoluteString)"
            )
        }
    }

    private static func isAlreadyScheduled(_ body: String) -> Bool {
        let lowercased = body.lowercased()
        return lowercased.contains("already") || lowercased.contains("scheduled")
    }
}
