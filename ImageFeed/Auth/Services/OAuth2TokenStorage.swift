import Foundation


final class OAuth2TokenStorage {
    private let tokenKey = "oauth2.token"
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }
}
