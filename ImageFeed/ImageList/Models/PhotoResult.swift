import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height, description
        case likedByUser = "liked_by_user"
        case urls
    }
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}
