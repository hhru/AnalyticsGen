// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Клик на кнопку написать в поддержку

 - **Описание**: Пользователь кликнул на какую-либо кнопку написания в поддержку
 - **Категория**: Поддержка
 */
struct SupportChatClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum CodingKeys: String, CodingKey {
        case buttonName = "buttonName"
        case employerID = "employerId"
        case hhtmSource
        case hhtmFrom
    }

    let eventName = "button_click"

    let hhtmSource: HHTMSource?
    let hhtmFrom: HHTMFrom?

    /// Какая-либо кнопка написания в поддержку
    let buttonName = "open_support_chat"

    /// ID работодателя (если есть)
    let employerID: String?

}
