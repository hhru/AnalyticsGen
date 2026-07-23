import Foundation

/// Поля Pull Request из ответа Forgejo API, которые нужны для работы с Autogen-PR
/// (декодируем только их, остальные поля ответа игнорируются).
struct PullRequestInfo: Decodable, Equatable {

    /// Состояние PR. Неизвестные значения декодируются в `.unknown`, чтобы не падать.
    enum State: String, Decodable {
        case open
        case closed
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = State(rawValue: raw) ?? .unknown
        }
    }

    struct Ref: Decodable, Equatable {
        let ref: String
        /// Имя ветки PR. В отличие от `ref`, сохраняется даже после merge с удалением ветки
        /// (`ref` тогда становится `refs/pull/<n>/head`). Для PR из форка имеет вид `owner:branch`.
        let label: String
        /// SHA head-коммита — для запроса сводного статуса чеков.
        let sha: String?
    }

    let number: Int
    let title: String
    let state: State
    let merged: Bool?
    /// `false` — merge-конфликт, auto-merge не сработает. Forgejo считает mergeability
    /// асинхронно: `nil` трактуется как «пока не конфликт», блокируемся только на явном `false`.
    let mergeable: Bool?
    let head: Ref
    let base: Ref
    let htmlURL: URL

    private enum CodingKeys: String, CodingKey {
        case number, title, state, merged, mergeable, head, base
        case htmlURL = "html_url"
    }
}

extension PullRequestInfo {

    /// PR относится к ветке `branch`. Сопоставляем по `head.label` — он переживает удаление ветки
    /// после merge (`head.ref` тогда становится `refs/pull/<n>/head`).
    func headMatches(branch: String) -> Bool {
        head.label == branch || head.label.hasSuffix(":\(branch)")
    }
}
