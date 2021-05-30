// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Клик на кнопку
/// **Описание**: Клик на кнопку "Исправить резюме", ведущую на веб
/// **Категория**: Профиль-резюме
struct ResumeCorrectionButtonClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case buttonName
        case hhtmSource
    }

    let eventName = "button_click"

    /// Кнопка "Исправить резюме"
    let buttonName = "resume_correction"

    /// Профиль-резюме
    let hhtmSource = "resume"

    var parameters: [ParameterKeys: Any?] {
        [
            .buttonName: buttonName,
            .hhtmSource: hhtmSource
        ]
    }
}
