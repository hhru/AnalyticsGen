// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Открыто боковое меню в профиле
/// **Описание**: Пользователь открыл боковое меню на вкладке профиля
/// **Категория**: Меню
/// **Эксперимент**:
/// https://jira.hh.ru/browse/PORTFOLIO-12642 (Запрос оценки или отзыва в приложении после позитивного опыта взаимодействия)
struct MenuScreenShowEventEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case hhtmSource
        case screenName
    }

    let eventName = "screen_shown"

    /// Боковое меню профиля
    let hhtmSource = "menu"

    /// Боковое меню профиля
    let screenName = "menu"

    var parameters: [ParameterKeys: Any?] {
        [
            .hhtmSource: hhtmSource,
            .screenName: screenName
        ]
    }
}
