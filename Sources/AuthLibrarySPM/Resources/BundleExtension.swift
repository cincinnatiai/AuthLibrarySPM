import Foundation

final class AuthManagerIdentifier {}

extension Bundle {
//    static var authManagerLocalizable: Bundle {
//        return Bundle(for: AuthManagerIdentifier.self)
//    }
    static var authManagerLocalizable: Bundle = {
        Bundle.module
    }()
}
