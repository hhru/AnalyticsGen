// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Нажатие на кнопку "Подтвердить номер" (баннер на профиле)

 - **Описание**: Нажатие на кнопку "Подтвердить номер" в баннере на экране профиля. Для опубликованных резюме.
 - **Категория**: Профиль-резюме
 */
struct ProfilePhoneVerificationBannerClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum CodingKeys: String, CodingKey {
        case hhtmSource
        case hhtmFrom
    }

    let eventName = "button_click"

    let hhtmSource: HHTMSource?
    let hhtmFrom: HHTMFrom?

}
