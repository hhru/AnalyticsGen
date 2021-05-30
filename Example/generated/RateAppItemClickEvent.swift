// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Клик на вариант ответа в боттомшите оценки приложения
/// **Описание**: Пользователь кликнул на вариант ответа в боттомшите оценки приложения
/// **Категория**: Оценка приложения
struct RateAppItemClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case buttonName
        case hhtmSource
    }

    enum Buttonname: String {
        /// Вариант ответа "Нравится"
        case like

        /// Вариант ответа "Не очень"
        case dislike

        /// Вариант ответа "Спасибо, не сейчас"
        case notNow
    }

    let eventName = "button_click"

    /// Боттомшит оценки приложения
    let hhtmSource = "app_rating_quiz"

    /// Кнопки вариантов ответов
    let buttonName: Buttonname

    var parameters: [ParameterKeys: Any?] {
        [
            .buttonName: buttonName.rawValue,
            .hhtmSource: hhtmSource
        ]
    }
}
