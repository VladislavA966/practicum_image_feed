import Foundation

struct UserResultModel: Codable {
    let profileImage: ProfileImageResultModel
    
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

