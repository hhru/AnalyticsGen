// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Новый пользователь на экране "Развилка"

 - **Описание**: Пользователь кликнул на "Я новый"
 - **Категория**: Онбоардинг
 */
public struct OnboardingDirectionClickNewUserEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    public enum CodingKeys: String, CodingKey {
        case hhtmSource
        case hhtmFrom
    }

    public let eventName = "onboardingNewUserClick"

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
