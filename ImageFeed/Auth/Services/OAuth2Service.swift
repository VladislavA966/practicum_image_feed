import Foundation

enum AuthServiceError: Error {
    case invalidRequestError
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private(set) var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }

    }

    private init() {}

    func fetchOAuthToken(
        code: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequestError))
            return
        }
        task?.cancel()
        lastCode = code
        guard let request = makeOAuth2Url(code: code) else {
            completion(.failure(AuthServiceError.invalidRequestError))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseModel, Error>) in
            guard let self else { return }
            switch result {
            case .success(let body):
                self.authToken = body.accessToken
                completion(.success(body.accessToken))
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        self.task = task
        task.resume()
    }

    private func makeOAuth2Url(code: String) -> URLRequest? {
        guard
            var urlComponents = URLComponents(
                string: "https://unsplash.com/oauth/token"
            )
        else { return nil }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else { return nil }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post
        return request
    }

}
