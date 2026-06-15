import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "oauth2.token"
    static let shared = OAuth2TokenStorage()
    private init() {}

    var token: String? {
        get { KeychainWrapper.standard.string(forKey: tokenKey) }
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }

    ///TODO: Временный метод для тестов, возможно пригодится когда будет делать логаут
    func clear() {
        token = nil
    }
}
