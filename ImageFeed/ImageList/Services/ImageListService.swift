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
    private var likeTask: URLSessionTask?

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

            case .failure(_):
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

    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        likeTask?.cancel()
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(
                .failure(
                    NSError(
                        domain: "ProfileImageService",
                        code: 401,
                        userInfo: [
                            NSLocalizedDescriptionKey:
                                "Authorization token missing"
                        ]
                    )
                )
            )
            return
        }

        guard
            let request = makeLikesUrlRequest(
                photoId: photoId,
                isLiked: isLiked,
                token: token
            )
        else {
            DispatchQueue.main.async {
                completion(.failure(URLError(.badURL)))
            }
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Запрос прошел успешно")
                    if let index = self.photos.firstIndex(where: {
                        $0.id == photoId
                    }) {
                        let photo = self.photos[index]
                        self.photos[index] = PhotoUIModel(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: isLiked
                        )
                    }
                    completion(.success(()))
                case .failure(let error):
                    print("Ошибка лайка \(error)")
                    completion(.failure(error))
                }
            }
        }
        self.likeTask = task
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
        photoId: String,
        isLiked: Bool,
        token: String
    ) -> URLRequest? {
        guard
            let url = URL(
                string: Constants.defaultBaseURLString
                    + "/photos/\(photoId)/like"
            )
        else { return nil }
        var request = URLRequest(url: url)
        print("Состояние которое мы передаем в запрос: \(isLiked)")
        request.httpMethod = isLiked ? HTTPMethod.post : HTTPMethod.delete
        print("Метод запроса \(request.httpMethod ?? "ПУСТО")")

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return request
    }

    func clearData() {
        task = nil
        photos = []
    }
}
