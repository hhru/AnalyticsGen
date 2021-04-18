// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Нажатие на кнопку "Подтвердить номер" (баннер на профиле)
/// **Описание**: Нажатие на кнопку "Подтвердить номер" в баннере на экране профиля. Для опубликованных резюме.
/// **Категория**: Профиль-резюме
struct ProfilePhoneVerificationBannerClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case hhtmSource
        case buttonName
    }

    let eventName = "button_click"

    /// Экран Профиль-резюме
    let hhtmSource = "resume"

    /// Баннер "Подтвердить номер телефона"
    let buttonName = "phone_verification_banner"

    var parameters: [ParameterKeys: Any] {
        [
            .hhtmSource: hhtmSource,
            .buttonName: buttonName
        ]
    }
}
