// swiftlint:disable all
// Generated using AnalyticsGen

import Foundation

/// **Название**: Отписка от автопоиска
/// **Описание**: Пользователь отключил уведомления подписки
/// **Категория**: Автопоиск
struct AutosearchUnsubscribeEvent: UserCategoryEvent {

    enum Label: String {
        /// Пользователь отключил уведомления подписки с автопоиска
        case autosearch

        /// Пользователь отключил уведомления подписки со списка автопоисков
        case autosearchList
    }

    let action = "autosearch-unsubscribe"

    let label: Label
    let isLoggedIn: Bool
}
