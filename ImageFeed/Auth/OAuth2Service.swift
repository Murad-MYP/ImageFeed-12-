import Foundation

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private let tokenStorage = OAuth2TokenStorage.storage
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() { }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if lastCode == code {
            completion(.failure(OAuthTokenRequestError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code

        switch makeOAuthTokenRequest(code: code) {
        case .success(let request):
            task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        self.tokenStorage.token = response.accessToken
                        completion(.success(response.accessToken))
                    case .failure(let error):
                        print("❌ Ошибка получения токена: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                    self.task = nil
                    self.lastCode = nil
                }
            }
            task?.resume()

        case .failure(let error):
            print("❌ Ошибка создания запроса: \(error)")
            completion(.failure(error))
        }
    }

    private func makeOAuthTokenRequest(code: String) -> Result<URLRequest, OAuthTokenRequestError> {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            return .failure(.invalidBaseURL)
        }

        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.path = "/oauth/token"
        components.queryItems = [
            .init(name: "client_id", value: Constants.accessKey),
            .init(name: "client_secret", value: Constants.secretKey),
            .init(name: "redirect_uri", value: Constants.redirectURI),
            .init(name: "code", value: code),
            .init(name: "grant_type", value: "authorization_code")
        ]

        guard let url = components.url else {
            return .failure(.invalidURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return .success(request)
    }
}
