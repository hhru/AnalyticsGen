// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Отписка от автопоиска

 - **Описание**: Пользователь отключил уведомления подписки
 - **Категория**: Автопоиск
 */
struct AutosearchUnsubscribeExternalEvent: UserCategoryEvent {

    enum Label: String {
        /// Пользователь отключил уведомления подписки с автопоиска
        case autosearch

        /// Пользователь отключил уведомления подписки со списка автопоисков
        case autosearchList
    }

    let action = "autosearch-unsubscribe"

    let isLoggedIn: Bool

    let oneOfLabel: Label

    var label: String {
        oneOfLabel.rawValue
    }
}
