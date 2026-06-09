import Foundation

struct ProfileUIModel {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

extension ProfileUIModel {
    static func from(profileData: ProfileResultModel?) -> ProfileUIModel {
        return ProfileUIModel(
            username: profileData?.username ?? "",
            name: profileData?.firstName ?? "",
            loginName: "@\(profileData?.username ?? "")",
            bio: profileData?.bio ?? ""
        )
    }
}
