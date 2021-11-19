// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Отписка от автопоиска

 - **Категория**: Автопоиск
 */
public struct AutosearchUnsubscribeExternalEvent: UserCategoryEvent {

    public enum Label: String {
        /// Пользователь отключил уведомления подписки с автопоиска
        case autosearch

        /// Пользователь отключил уведомления подписки со списка автопоисков
        case autosearchList
    }

    public let action = "autosearch-unsubscribe"

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
