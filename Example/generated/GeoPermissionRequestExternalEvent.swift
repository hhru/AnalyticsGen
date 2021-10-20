// swiftlint:disable all
// Generated using AnalyticsGen

import Analytics

/**
 Запрос на определение геопозиции

 - **Описание**: У пользователя запросили разрешение на гео
 - **Категория**: Разрешения
 */
public struct GeoPermissionRequestExternalEvent: UserCategoryEvent {

    public enum Label: String {
        /// У пользователя запросили разрешение на гео
        case requestOpen
    }

    public let action = "request-geo-permission"

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
