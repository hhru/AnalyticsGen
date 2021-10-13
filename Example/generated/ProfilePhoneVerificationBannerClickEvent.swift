// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Нажатие на кнопку "Подтвердить номер" (баннер на профиле)

 - **Описание**: Нажатие на кнопку "Подтвердить номер" в баннере на экране профиля. Для опубликованных резюме.
 - **Категория**: Профиль-резюме
 */
public struct ProfilePhoneVerificationBannerClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    public enum CodingKeys: String, CodingKey {
        case hhtmSource
        case hhtmFrom
    }

    public let eventName = "button_click"

    public let hhtmSource: HHTMSource?
    public let hhtmFrom: HHTMSource?

    public init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMSource?
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
    }
}
