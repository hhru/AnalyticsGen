import Foundation

enum EventPlatform: String, Decodable {

    case android = "Android"
    case iOSAndroid = "Android/iOS"
    case iOS
}

extension EventPlatform: Equatable {

    static func == (lhs: EventPlatform, rhs: EventPlatform) -> Bool {
        switch (lhs, rhs) {
        case (.android, .android):
            return true

        case (.android, .iOSAndroid):
            return true

        case (.android, .iOS):
            return false

        case (.iOSAndroid, .android):
            return true

        case (.iOSAndroid, .iOSAndroid):
            return true

        case (.iOSAndroid, .iOS):
            return true

        case (.iOS, .android):
            return false

        case (.iOS, .iOSAndroid):
            return true

        case (.iOS, .iOS):
            return true
        }
    }
}
