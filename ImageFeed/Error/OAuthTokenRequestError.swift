// MARK: - OAuth Errors

import Foundation

enum OAuthTokenRequestError: Error {
    case invalidBaseURL
    case invalidURL
    case invalidRequest
}

// MARK: - Network Errors

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidResponseData
    case missingToken
    case requestFailed
}

// MARK: - Images List Service Errors

enum ImagesListServiceError: Error {
    case missingToken
    case urlRequestError(Error)
}
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.invalidResponseData))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
        return task
    }
}
