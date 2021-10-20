// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Нажатие на кнопку "Сохранить" на текущем шаге визарда

 - **Описание**: Пользователь заполнил текущий шаг визарда и нажал на кнопку "Сохранить", после чего либо перешел на следующий шаг, либо увидел ошибки валидации полей.
 - **Категория**: Профиль-резюме
 */
public struct ResumeWizardStepSaveResultEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    public enum CodingKeys: String, CodingKey {
        case resumeHash = "resumeHash"
        case type = "type"
        case screenType = "screenType"
        case errors = "errors"
        case hhtmSource
        case hhtmFrom
    }

    public enum EventType: String, Encodable {
        /// Визард для дозаполнения резюме
        case completion = "completion"

        /// Визард для разблокировки резюме
        case correction = "correction"

        /// Визард для создания резюме
        case creation = "creation"

        /// Визард для дублирования резюме
        case duplication = "duplication"
    }

    public enum ScreenType: String, Encodable {
        case profile = "profile"

        case resumeList = "resume_list"
    }

    /// Название события
    public let eventName = "resume_wizard_step_save_result"

    /// С какого экрана событие будет отправлено
    public let hhtmSource: HHTMSource?

    /// Предыдущий экран
    public let hhtmFrom: HHTMSource?

    /// Идентификатор резюме
    public let resumeHash: String

    /// Тип визарда
    public let type: EventType

    public let screenType: ScreenType

    /**
    Список ошибок валидации на текущем шаге визарда в виде JSON-строки,
    где ключ - поле резюме, а значение - причина ошибки. Например:
    ```
    "{
        "first_name": "required",
        "last_name": "required",
        "gender": "required",
        "contact/0/value": "phone_number",
        "contact/1/value": "email_address",
        "area": "required",
        "citizenship": "min_length"
    }"
    ```
    */
    public let errors: String

    public init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMSource?,
        resumeHash: String,
        type: EventType,
        screenType: ScreenType,
        errors: String
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.resumeHash = resumeHash
        self.type = type
        self.screenType = screenType
        self.errors = errors
    }
}
