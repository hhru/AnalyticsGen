// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Новый пользователь на экране "Развилка"
/// **Описание**: Пользователь кликнул на "Я новый"
/// **Категория**: Онбоардинг
struct OnboardingDirectionClickNewUserEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent, UserCategoryEvent {

    enum ParameterKeys: String {
    }


    enum Label: String {
        /// --
        case success
    }

    let eventName = "onboardingNewUserClick"
    let action = "onboarding-direction-click-new-user"


    let label: Label = .success
    let isLoggedIn: Bool

    var parameters: [ParameterKeys: Any?] {
        [
        ]
    }
}
