// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Открытие уведомления

 - **Описание**: Пользователь кликнул на уведомление на экране "Уведомления"
 - **Категория**: Разное
 */
struct ClickNotificationExternalEvent: UserCategoryEvent {

    enum Label: String {
        /// Пользователь нажал «Оценить приложение» во всплывающем уведомлении
        case notifications

        /// Пользователь нажал «Оценить приложение» на экране «Еще»
        case elsePage
    }

    let action = "click-notification"

    let isLoggedIn: Bool

    let oneOfLabel: Label

    var label: String {
        oneOfLabel.rawValue
    }
}
