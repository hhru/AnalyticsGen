// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Клик на кнопку написать в поддержку
/// **Описание**: Пользователь кликнул на какую-либо кнопку написания в поддержку
/// **Категория**: Поддержка
struct SupportChatClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case buttonName
        case hhtmSource
        case hhtmFrom
    }

    enum Hhtmsource: String {
        /// В боттомшите/диалоге оценки приложения
        case appRatingSupport

        /// На экране "Помощь"
        case help
    }

    enum Hhtmfrom: String {
        /// Боттомшита оценки приложения
        case appRatingQuiz

        /// Диалога оценки приложения
        case appRatingStars

        /// Экрана "Помощь"
        case help
    }

    let eventName = "button_click"

    /// Какая-либо кнопка написания в поддержку
    let buttonName = "open_support_chat"

    /// Где находится кнопка
    let hhtmSource: Hhtmsource

    /// После открытия какого экрана была нажата кнопка
    let hhtmFrom: Hhtmfrom

    var parameters: [ParameterKeys: Any?] {
        [
            .buttonName: buttonName,
            .hhtmSource: hhtmSource.rawValue,
            .hhtmFrom: hhtmFrom.rawValue
        ]
    }
}
