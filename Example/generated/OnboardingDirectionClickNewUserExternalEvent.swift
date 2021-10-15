// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Новый пользователь на экране "Развилка"

 - **Описание**: Пользователь кликнул на "Я новый"
 - **Категория**: Онбоардинг
 */
public struct OnboardingDirectionClickNewUserExternalEvent: UserCategoryEvent {

    public enum Label: String {
        /// --
        case success
    }

    public let action = "onboarding-direction-click-new-user"

    public let oneOfLabel: Label

    public var label: String {
        oneOfLabel.rawValue
    }

    public let isLoggedIn: Bool

    public init(
        label: Label,
        isLoggedIn: Bool
    ) {
        self.oneOfLabel = label
        self.isLoggedIn = isLoggedIn
    }
}
