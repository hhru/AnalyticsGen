import Foundation

enum EventPlatform: String, Decodable {

    // MARK: - Enumeration Cases

    case android = "Android"
    case androidIOS = "Android/iOS"
    case iOS
}

// MARK: -

extension EventPlatform: Equatable {

    // MARK: - Type Methods

    static func == (lhs: EventPlatform, rhs: EventPlatform) -> Bool {
        switch (lhs, rhs) {
        case (.android, .android):
            return true

        case (.android, .androidIOS):
            return true

        case (.android, .iOS):
            return false

        case (.androidIOS, .android):
            return true

        case (.androidIOS, .androidIOS):
            return true

        case (.androidIOS, .iOS):
            return true

        case (.iOS, .android):
            return false

        case (.iOS, .androidIOS):
            return true

        case (.iOS, .iOS):
            return true
        }
    }
}
