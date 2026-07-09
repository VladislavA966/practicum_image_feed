import Foundation

final class ImageListService {
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    static let didFaultNotification = Notification.Name(
        rawValue: "ImagesListServiceDidFault"
    )
    private let urlSession = URLSession.shared
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private var task: URLSessionTask?

    private(set) var photos: [PhotoUIModel] = []

    private var lastLoadedPage: Int?

    private init() {}

    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard task == nil else { return }

        guard let request = makeImageListRequest(page: nextPage) else {
            return
        }

        let task = urlSession.objectTask(for: request, decoder: decoder) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer { self.task = nil }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { PhotoUIModel(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self
                    )
                }

            case .failure(let error):
                print("fetchPhotosNextPage error: \(error)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ImageListService.didFaultNotification,
                        object: self
                    )
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeImageListRequest(page: Int, perPage: Int = 10)
        -> URLRequest?
    {
        guard
            var components = URLComponents(
                string: Constants.defaultBaseURLString + "/photos"
            )
        else { return nil }

        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        } else {
            request.setValue(
                "Client-ID \(Constants.accessKey)",
                forHTTPHeaderField: "Authorization"
            )
        }

        return request
    }

    private func makeLikesUrlRequest(
        imageId: String,
        isLiked: Bool,
        token: String
    ) -> URLRequest? {
        guard
            let url = URL(
                string: "https://api.unsplash.com/photos/\(imageId)/likes"
            )
        else { return nil }
        var request = URLRequest(url: url)
        if isLiked {
            request.httpMethod = HTTPMethod.delete
        } else {
            request.httpMethod = HTTPMethod.post
        }
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }
}
