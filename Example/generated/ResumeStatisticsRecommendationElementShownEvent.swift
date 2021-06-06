// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Показ рекомендации
/// **Описание**: Пользователь увидел рекомендацию
/// **Категория**: Профиль-резюме
struct ResumeStatisticsRecommendationElementShownEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case elementName
        case hhtmSource
        case type
        case resumeHash
    }

    enum HHTMSource: String {
        /// Экран список резюме со статистикой
        case resumeList

        /// Экран резюме-профиля
        case resume
    }

    let eventName = "element_shown"

    /// Наименование элемента
    let elementName = "recommendation"

    /// Тип рекоммендации на которую нажали (откликайся, сделай видимым и т.п.)
    let type: String

    /// ID резюме из API
    let resumeHash: String

    /// Экран, на котором была показана рекомендация
    let hhtmSource: HHTMSource

    var parameters: [ParameterKeys: Any?] {
        [
            .elementName: elementName,
            .hhtmSource: hhtmSource.rawValue,
            .type: type,
            .resumeHash: resumeHash
        ]
    }
}
