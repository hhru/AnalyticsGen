// swiftlint:disable all
// Generated using AnalyticsGen

import Foundation

/// **Название**: Открытие уведомления
/// **Описание**: Пользователь кликнул на уведомление на экране "Уведомления"
/// **Категория**: Разное
struct ClickNotificationEvent: UserCategoryEvent {

    enum Label: String {
        /// Пользователь нажал «Оценить приложение» во всплывающем уведомлении
        case notifications

        /// Пользователь нажал «Оценить приложение» на экране «Еще»
        case elsePage
    }

    let action = "click-notification"

    let label: Label
    let isLoggedIn: Bool
}
