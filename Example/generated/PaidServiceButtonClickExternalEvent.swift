// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Нажатие на платный сервис

 - **Описание**: Пользователь нажал на платный сервис
 - **Категория**: Соискательские сервисы
 */
public struct PaidServiceButtonClickExternalEvent: UserCategoryEvent {

    public enum Label: String {
        /// Список платных услуг
        case serviceList
    }

    /// Строится как buy-{service_id}-attempt
    public let action: String

    public let oneOfLabel: Label

    public var label: String {
        oneOfLabel.rawValue
    }

    public let isLoggedIn: Bool

    public init(
        action: String,
        label: Label,
        isLoggedIn: Bool
    ) {
        self.action = action
        self.oneOfLabel = label
        self.isLoggedIn = isLoggedIn
    }
}
