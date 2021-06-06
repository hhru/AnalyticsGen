// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Закрытие экрана "Развилка"
/// **Описание**: Пользователь кликнул на крестик
/// **Категория**: Онбоардинг
struct OnboardingDirectionCloseEvent: InternalAnalyticsEvent, SlashAnalyticsEvent, UserCategoryEvent {

    enum Label: String {
        /// --
        case success
    }

    let eventName = "onboardingClose"
    let action = "onboarding-direction-show"

    let label: Label = .success
    let isLoggedIn: Bool

}
