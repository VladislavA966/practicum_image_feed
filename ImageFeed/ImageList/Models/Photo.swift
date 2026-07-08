import Foundation

struct PhotoUIModel {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

extension PhotoUIModel {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: CGFloat(result.width), height: CGFloat(result.height))
        self.createdAt = result.createdAt
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
}
