import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        cleanCookies()
        cleanProfileData()
        ImageListService.shared.clearData()
        OAuth2TokenStorage.shared.clear()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in

            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record],
                    completionHandler: {}
                )
            }
        }
    }

    private func cleanProfileData() {
        ProfileImageService.shared.clearImageData()
        ProfileService.shared.clearData()
    }

}
