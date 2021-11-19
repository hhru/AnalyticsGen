// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Открытие главного экрана и изменение карточек

 - **Описание**: У пользователя обновились карточки на главном экране
 - **Категория**: Главный экран
 */
public struct MainScreenShowEvent:
    ParametrizedInternalAnalyticsEvent,
    SlashAnalyticsEvent,
    ScreenAnalyticsKeyContainable {

    public enum CodingKeys: String, CodingKey {
        case screenName = "screenName"
        case actionCardList = "actionCardList"
        case hhtmSource
        case hhtmFrom
    }

    public enum ActionCardList: String, Encodable {
        /// Комбинация с карточкой обновления резюме, когда обновление недоступно
        case workNearbyResumeUpdateGreySIDeJobAdviceArticle = "work_nearby,resume_update_grey,side_job,advice_article"

        /// Комбинация с карточкой обновления резюме, когда обновление доступно
        case workNearbyResumeUpdateGreenSIDeJobAdviceArticle = "work_nearby,resume_update_green,side_job,advice_article"

        /// Комбинация с карточкой получить больше просмотров
        case resumeCompleteWorkNearbySIDeJobAdviceArticle = "resume_complete,work_nearby,side_job,advice_article"

        /// Комбинация с "Создать первое резюме"
        case resumeCreationWorkNearbySIDeJobAdviceArticle = "resume_creation,work_nearby,side_job,advice_article"

        /// Комбинация с "Шаги до готового резюме"
        case resumePublicationWorkNearbySIDeJobAdviceArticle = "resume_publication,work_nearby,side_job,advice_article"

        /// Комбинация с "Блокировка резюме"
        case resumeCorrectionWorkNearbySIDeJobAdviceArticle = "resume_correction,work_nearby,side_job,advice_article"

        /// Комбинация с "Получить свое первое приглашение"
        case firstResponseWorkNearbySIDeJobAdviceArticle = "first_response,work_nearby,side_job,advice_article"

        /// Комбинация с "Откликнитесь еще на N вакансий"
        case responseCountWorkNearbySIDeJobAdviceArticle = "response_count,work_nearby,side_job,advice_article"

        /// Комбинация с карточкой последнего поиска
        case lastSearchWorkNearbySIDeJobAdviceArticle = "last_search,work_nearby,side_job,advice_article"
    }

    /// Название события
    public let eventName = "screen_shown"

    /// С какого экрана событие будет отправлено
    public let hhtmSource: HHTMSource?

    /// Предыдущий экран
    public let hhtmFrom: HHTMSource?

    /// У пользователя обновились карточки на главном экране
    public let screenName = "main"

    /// Могут быть еще
    public let actionCardList: ActionCardList

    public init(
        hhtmSource: HHTMSource?, 
        hhtmFrom: HHTMSource?,
        actionCardList: ActionCardList
    ) {
        self.hhtmSource = hhtmSource
        self.hhtmFrom = hhtmFrom
        self.actionCardList = actionCardList
    }
}
