// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Нажатие на платный сервис

 - **Описание**: Пользователь нажал на платный сервис
 - **Категория**: Соискательские сервисы
 */
public struct PaidServiceButtonClickEvent:
    ParametrizedInternalAnalyticsEvent,
    SlashAnalyticsEvent {

    public enum CodingKeys: String, CodingKey {
        case buttonName = "buttonName"
        case hhtmSource
        case hhtmFrom
    }

    /// Название события
    public let eventName = "button_click"

    /// С какого экрана событие будет отправлено
    public let hhtmSource: HHTMSource?

    /// Предыдущий экран
    public let hhtmFrom: HHTMSource?

    /// Строится как applicant_services_{serviceID}
    public let buttonName: String

    public init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMSource?,
        buttonName: String
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.buttonName = buttonName
    }
}
