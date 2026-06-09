import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private(set) var profileUIModel: ProfileUIModel?
    
    private init() {}

    func fetch(
        token: String,
        completion: @escaping (Result<ProfileUIModel, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                guard let self = self else { return }
                do {
                    let profileData = try self.decoder.decode(ProfileResultModel.self, from: data)
                    let profileUIModel = ProfileUIModel.from(profileData: profileData)
                    self.profileUIModel = profileUIModel
                    completion(.success(profileUIModel))
                } catch {
                    completion(.failure(error))
                }
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
        request.setValue("Bearer \(token)",forHTTPHeaderField: "Authorization")
        return request
    }
}
