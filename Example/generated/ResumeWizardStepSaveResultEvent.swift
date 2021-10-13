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
        case errors = "errors"
        case hhtmSource
        case hhtmFrom
    }

    public enum `Type`: String, Encodable {
        /// Визард для дозаполнения резюме
        case completion = "completion"

        /// Визард для разблокировки резюме
        case correction = "correction"

        /// Визард для создания резюме
        case creation = "creation"

        /// Визард для дублирования резюме
        case duplication = "duplication"
    }

    public let eventName = "resume_wizard_step_save_result"

    public let hhtmSource: HHTMSource?
    public let hhtmFrom: HHTMSource?

    /// Идентификатор резюме
    public let resumeHash: String

    /// Тип визарда
    public let type: `Type`

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
        type: `Type`,
        errors: String
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.resumeHash = resumeHash
        self.type = type
        self.errors = errors
    }
}
