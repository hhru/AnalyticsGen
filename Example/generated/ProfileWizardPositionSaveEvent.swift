// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Пользователь выбрал должность
/// **Описание**: Пользователь выбрал должность, он мог сделать это как в форме через накликивание (`type == tag`) В форме подсказки должности либо выбрать подходящий вариант (`type == suggest`) или же ввести что-то свое руками (`type == manual`)
/// **Категория**: Профиль-резюме
struct ProfileWizardPositionSaveEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case buttonName = "buttonName"
        case type = "type"
    }

    enum `Type`: String {
        /// экран накликивания
        case tag = "tag"

        /// экран подсказки + выбрали подсказку (не ручной ввод)
        case suggest = "suggest"

        /// кран подсказки ручной ввод
        case manual = "manual"
    }

    let eventName = "button_click"

    /// Пользователь выбрал должность
    let buttonName = "profile_wizard_position_save"

    /// Тип экрана выбора должности
    let type: `Type`

    var parameters: [ParameterKeys: Any?] {
        [
            .buttonName: buttonName,
            .type: type.rawValue
        ]
    }
}
