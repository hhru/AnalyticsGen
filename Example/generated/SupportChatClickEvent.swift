// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Клик на кнопку написать в поддержку

 - **Описание**: Пользователь кликнул на какую-либо кнопку написания в поддержку
 - **Категория**: Поддержка
 */
public struct SupportChatClickEvent:
    ParametrizedInternalAnalyticsEvent,
    SlashAnalyticsEvent {

    public enum CodingKeys: String, CodingKey {
        case buttonName = "buttonName"
        case employerID = "employerId"
        case hhtmSource
        case hhtmFrom
    }

    /// Название события
    public let eventName = "button_click"

    /// С какого экрана событие будет отправлено
    public let hhtmSource: HHTMSource?

    /// Предыдущий экран
    public let hhtmFrom: HHTMSource?

    /// Какая-либо кнопка написания в поддержку
    public let buttonName = "open_support_chat"

    /// ID работодателя (если есть)
    public let employerID: String?

    public init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMSource?,
        employerID: String?
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.employerID = employerID
    }
}
