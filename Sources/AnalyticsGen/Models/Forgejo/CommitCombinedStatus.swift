import Foundation

/// Сводный статус чеков коммита (`GET repos/{owner}/{repo}/commits/{ref}/status`).
struct CommitCombinedStatus: Decodable {

    /// Статус чека. Неизвестные значения (в том числе пустую строку при `total_count == 0`)
    /// декодируем в `.unknown`, чтобы не падать.
    enum State: String, Decodable {
        case pending
        case success
        case error
        case failure
        case warning
        case unknown

        init(from decoder: Decoder) throws {
            let raw = try decoder.singleValueContainer().decode(String.self)
            self = State(rawValue: raw) ?? .unknown
        }

        /// Терминальный статус, при котором auto-merge (требующий success) никогда не сработает.
        var isBlocking: Bool {
            self == .error || self == .failure || self == .warning
        }
    }

    struct Status: Decodable {
        /// Статус элемента: в JSON приходит в ключе `status` (не `state`).
        let state: State
        /// Имя чека, напр. "Mobile/CheckPRToMobileAnalytics/pipeline/pr-develop-ios".
        let context: String

        private enum CodingKeys: String, CodingKey {
            case state = "status"
            case context
        }
    }

    /// Агрегат по всем чекам; при `total_count == 0` Forgejo отдаёт `""` → `.unknown` (не blocking).
    let state: State
    let totalCount: Int
    let statuses: [Status]

    private enum CodingKeys: String, CodingKey {
        case state, statuses
        case totalCount = "total_count"
    }
}
