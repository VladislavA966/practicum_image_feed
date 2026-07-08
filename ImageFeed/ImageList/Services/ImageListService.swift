import Foundation

final class ImageListService {
    static let shared = ImageListService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
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

    func fetchPhotosNextPage(
        completion: @escaping (Result<[PhotoUIModel], Error>) -> Void
    ) {
        let nextPage = (lastLoadedPage ?? 0) + 1

        guard task == nil else { return }

        guard let request = makeImageListRequest(page: nextPage) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request, decoder: decoder) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer { self.task = nil }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map {
                    PhotoUIModel.init(from: $0)
                }
                self.photos.append(contentsOf: newPhotos)
                NotificationCenter.default.post(
                    name: ImageListService.didChangeNotification,
                    object: self
                )
                lastLoadedPage = nextPage

            case .failure(let error):
                completion(.failure(error))

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
}
