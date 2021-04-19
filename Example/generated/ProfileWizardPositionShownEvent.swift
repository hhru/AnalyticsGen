// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Пользователь открыл экран "Желаемая должность"
/// **Описание**: Пользователь открыл экран "Желаемая должность" в новом формате
/// **Категория**: Профиль-резюме
struct ProfileWizardPositionShownEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case screenName
        case currentStepNumber
        case totalStepsCount
    }

    let eventName = "screenShown"

    /// Пользователь открыл экран "Желаемая должность"
    let screenName = "profile_wizard_position"

    /// Номер текущего шага
    let currentStepNumber: Int

    /// Общее количество шагов в визарде
    let totalStepsCount: Int

    var parameters: [ParameterKeys: Any] {
        [
            .screenName: screenName,
            .currentStepNumber: currentStepNumber,
            .totalStepsCount: totalStepsCount
        ]
    }
}
