import Foundation

/// Ошибка планирования merge PR в Forgejo.
enum ForgejoMergeError: Error, CustomStringConvertible {
    /// Forgejo отклонил merge: HTTP-код и тело ответа
    /// (напр. 409 "already scheduled", 405 "not allowed to merge").
    case rejected(code: Int, body: String)

    var description: String {
        switch self {
        case let .rejected(code, body):
            return "Forgejo rejected merge scheduling (HTTP \(code)): \(body)"
        }
    }
}
