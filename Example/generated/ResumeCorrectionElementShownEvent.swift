// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Показ кнопки
/// **Описание**: Показ кнопки "Исправить резюме", ведущей на веб
/// **Категория**: Профиль-резюме
struct ResumeCorrectionElementShownEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case elementName
        case hhtmSource
    }

    let eventName = "element_shown"

    /// Кнопка "Исправить резюме"
    let elementName = "resume_correction"

    /// Профиль-резюме
    let hhtmSource = "resume"

    var parameters: [ParameterKeys: Any?] {
        [
            .elementName: elementName,
            .hhtmSource: hhtmSource
        ]
    }
}
