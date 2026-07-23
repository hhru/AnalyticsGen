import Foundation

/// Операции Forgejo API над Pull Request, нужные для Autogen-PR.
protocol ForgejoPullRequestService {

    /// Ищет первый PR с указанным `head` (и, если задан, `base`) среди PR в состоянии `state`.
    func findPullRequest(
        owner: String,
        repo: String,
        head: String,
        base: String?,
        state: String
    ) async throws -> PullRequestInfo?

    /// Ищет analyst-PR по имени ветки: открытый — по `head.ref`, либо смерженный — по префиксу
    /// заголовка (после merge ветка удаляется, и `head.ref` перестаёт совпадать с именем ветки).
    func findAnalystPullRequest(
        owner: String,
        repo: String,
        branch: String
    ) async throws -> PullRequestInfo?

    /// Создаёт PR и возвращает его номер.
    func createPullRequest(
        owner: String,
        repo: String,
        head: String,
        base: String,
        title: String,
        body: String,
        labels: [Int]
    ) async throws -> Int

    /// Возвращает свежее состояние PR по номеру (state / merged / mergeable / head.sha).
    func getPullRequest(
        owner: String,
        repo: String,
        number: Int
    ) async throws -> PullRequestInfo

    /// Возвращает сводный статус чеков для ref (обычно head.sha PR).
    func getCommitStatus(
        owner: String,
        repo: String,
        ref: String
    ) async throws -> CommitCombinedStatus

    /// Планирует merge PR: вольётся сразу, если чеки зелёные, иначе — когда позеленеют.
    /// - Throws: `ForgejoMergeError.rejected` c HTTP-кодом и телом, если Forgejo отклонил запрос.
    func scheduleMerge(
        owner: String,
        repo: String,
        number: Int,
        method: String,
        deleteBranchAfterMerge: Bool
    ) async throws
}
