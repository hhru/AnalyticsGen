// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Новый пользователь на экране "Развилка"

 - **Описание**: Пользователь кликнул на "Я новый"
 - **Категория**: Онбоардинг
 */
struct OnboardingDirectionClickNewUserExternalEvent: UserCategoryEvent {

    enum Label: String {
        /// --
        case success
    }

    let action = "onboarding-direction-click-new-user"

    let isLoggedIn: Bool

    let oneOfLabel: Label

    var label: String {
        oneOfLabel.rawValue
    }
}
