// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Открыт боттомшит оценки приложения
/// **Описание**: Пользователь открыл боттомшит оценки приложения
/// **Категория**: Оценка приложения
/// **Эксперимент**:
/// https://jira.hh.ru/browse/PORTFOLIO-12642 (Запрос оценки или отзыва в приложении после позитивного опыта взаимодействия)
struct RateAppBottomsheetScreenShowEventEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case hhtmSource
        case screenName
    }

    let eventName = "screen_shown"

    /// Боттомшит оценки приложения
    let hhtmSource = "app_rating_quiz"

    /// Боттомшит оценки приложения
    let screenName = "app_rating_quiz"

    var parameters: [ParameterKeys: Any?] {
        [
            .hhtmSource: hhtmSource,
            .screenName: screenName
        ]
    }
}
