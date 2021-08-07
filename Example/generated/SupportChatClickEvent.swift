// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/// **Название**: Клик на кнопку написать в поддержку
/// **Описание**: Пользователь кликнул на какую-либо кнопку написания в поддержку
/// **Категория**: Поддержка
/// **Эксперимент**:
/// https://jira.hh.ru/browse/PORTFOLIO-12642 (Запрос оценки или отзыва в приложении после позитивного опыта взаимодействия)
struct SupportChatClickEvent: ParametrizedInternalAnalyticsEvent, SlashAnalyticsEvent {

    enum ParameterKeys: String {
        case buttonName
        case hhtmSource
        case hhtmFrom
        case employerId
    }

    let eventName = "button_click"

    /// Какая-либо кнопка написания в поддержку
    let buttonName = "open_support_chat"

    /// Где находится кнопка
    let hhtmSource = HHTMSource.Applicant.employerScreen

    /// После открытия какого экрана была нажата кнопка
    let hhtmFrom: HHTMSource?

    /// ID работодателя (если есть)
    let employerId: String?

    var parameters: [ParameterKeys: Any?] {
        [
            .buttonName: buttonName,
            .hhtmSource: hhtmSource.value,
            .hhtmFrom: hhtmFrom?.value,
            .employerId: employerId
        ]
    }
}
