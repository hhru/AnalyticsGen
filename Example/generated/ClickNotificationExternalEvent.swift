// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Открытие уведомления

 - **Описание**: Пользователь кликнул на уведомление на экране "Уведомления"
 - **Категория**: Разное
 */
public struct ClickNotificationExternalEvent: UserCategoryEvent {

    public enum Label: String {
        /// Пользователь нажал «Оценить приложение» во всплывающем уведомлении
        case notifications

        /// Пользователь нажал «Оценить приложение» на экране «Еще»
        case elsePage
    }

    public let action = "click-notification"

    public let oneOfLabel: Label

    public var label: String {
        oneOfLabel.rawValue
    }

    public let isLoggedIn: Bool

    public init(
        label: Label,
        isLoggedIn: Bool
    ) {
        self.oneOfLabel = label
        self.isLoggedIn = isLoggedIn
    }
}
