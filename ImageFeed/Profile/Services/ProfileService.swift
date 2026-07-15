import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private(set) var profileUIModel: ProfileUIModel?

    private init() {}

    func fetch(
        completion: @escaping (Result<ProfileUIModel, Error>) -> Void
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

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<ProfileResultModel, Error>) in
            switch result {
            case .success(let profileData):
                guard let self = self else { return }
                let profileUIModel = ProfileUIModel.from(
                    profileData: profileData
                )
                self.profileUIModel = profileUIModel
                completion(.success(profileUIModel))
            case .failure(let error):
                completion(.failure(error))
                print("Error \(error)")
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: Constants.defaultBaseURLString + "/me")
        else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func clearData() {
        profileUIModel = nil
        task = nil
    }
}
