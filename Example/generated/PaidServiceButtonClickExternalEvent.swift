// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics
import SharedServices

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
