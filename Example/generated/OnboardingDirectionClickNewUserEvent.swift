// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Новый пользователь на экране "Развилка"

 - **Описание**: Пользователь кликнул на "Я новый"
 - **Категория**: Онбоардинг
 */
struct OnboardingDirectionClickNewUserEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum CodingKeys: String, CodingKey {
        case hhtmSource
        case hhtmFrom
    }

    let eventName = "onboardingNewUserClick"

    let hhtmSource: HHTMSource?
    let hhtmFrom: HHTMFrom?

}
