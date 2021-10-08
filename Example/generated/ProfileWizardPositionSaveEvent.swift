// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Пользователь выбрал должность

 - **Описание**: Пользователь выбрал должность, он мог сделать это как в форме через накликивание (`type == tag`) В форме подсказки должности либо выбрать подходящий вариант (`type == suggest`) или же ввести что-то свое руками (`type == manual`)
 - **Категория**: Профиль-резюме
 */
public struct ProfileWizardPositionSaveEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    public enum CodingKeys: String, CodingKey {
        case buttonName = "buttonName"
        case type = "type"
        case hhtmSource
        case hhtmFrom
    }

    public enum `Type`: String, Encodable {
        /// экран накликивания
        case tag = "tag"

        /// экран подсказки + выбрали подсказку (не ручной ввод)
        case suggest = "suggest"

        /// кран подсказки ручной ввод
        case manual = "manual"
    }

    public let eventName = "button_click"

    public let hhtmSource: HHTMSource?
    public let hhtmFrom: HHTMFrom?

    /// Пользователь выбрал должность
    public let buttonName = "profile_wizard_position_save"

    /// Тип экрана выбора должности
    public let type: `Type`

    public init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMFrom,
        type: `Type`
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.type = type
    }
}
