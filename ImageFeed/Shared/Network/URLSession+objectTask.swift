import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        return self.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
