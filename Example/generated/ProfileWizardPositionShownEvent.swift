// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Пользователь открыл экран "Желаемая должность"
/// **Описание**: Пользователь открыл экран "Желаемая должность" в новом формате
/// **Категория**: Профиль-резюме
struct ProfileWizardPositionShownEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case totalStepsCount
        case currentStepNumber
        case screenName
    }

    let eventName = "screenShown"

    /// Пользователь открыл экран "Желаемая должность"
    let screenName = "profile_wizard_position"

    /// Общее количество шагов в визарде
    let totalStepsCount: Int

    /// Номер текущего шага
    let currentStepNumber: Int

    var parameters: [ParameterKeys: Any] {
        [
            .totalStepsCount: totalStepsCount,
            .currentStepNumber: currentStepNumber,
            .screenName: screenName
        ]
    }
}
