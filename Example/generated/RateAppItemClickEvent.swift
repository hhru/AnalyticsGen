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

    enum ButtonName: String {
        /// Вариант ответа "Нравится"
        case like = "like"

        /// Вариант ответа "Не очень"
        case dislike = "dislike"

        /// Вариант ответа "Спасибо, не сейчас"
        case notNow = "not_now"
    }

    let eventName = "button_click"

    /// Боттомшит оценки приложения
    let hhtmSource = "app_rating_quiz"

    /// Кнопки вариантов ответов
    let buttonName: ButtonName

    var parameters: [ParameterKeys: Any?] {
        [
            .buttonName: buttonName.rawValue,
            .hhtmSource: hhtmSource
        ]
    }
}
