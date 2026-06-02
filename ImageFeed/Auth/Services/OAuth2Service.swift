import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

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
        request.httpMethod = "POST"
        return request
    }
    
    
    func fetchOAuthToken(code: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuth2Url(code: code) else {
              print("❌ [OAuth2Service] Failed to create URLRequest for code: \(code)")  // 1
              return
          }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let body = try JSONDecoder().decode(OAuthTokenResponseModel.self, from: data)
                    OAuth2TokenStorage.shared.token = body.accessToken
                    completion(.success(body.accessToken))
                } catch {
                    print("❌ [OAuth2Service] Decoding error: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("❌ [OAuth2Service] Network error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
