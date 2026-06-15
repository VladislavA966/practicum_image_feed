import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return self.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let json = String(data: data, encoding: .utf8)
                    print(json ?? "Нет данных")
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                    print("Ошибка декодирования JSON: \(error)")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
