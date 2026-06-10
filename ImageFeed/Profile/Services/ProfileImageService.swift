import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private(set) var imageUrl: String?

    private init() {}

    func fetchProfileImageUrl(
        name: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

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

        guard let request = makeProfileImageRequest(name: name, token: token)
        else { return }

        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self = self else { return }
                do {
                    let profileImageData = try self.decoder.decode(
                        ProfileImageResultModel.self,
                        from: data
                    )
                    self.imageUrl = profileImageData.small
                    completion(.success(profileImageData.small))
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": self.imageUrl ?? ""]
                        )
                } catch {
                    print("adadadasda")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(name: String, token: String)
        -> URLRequest?
    {
        guard
            let url = URL(
                string: Constants.defaultBaseURLString + "/users/\(name)"
            )
        else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.get
        urlRequest.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        return urlRequest
    }
}
