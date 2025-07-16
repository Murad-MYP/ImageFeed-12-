import Foundation
import Kingfisher

final class ProfileImageService {
    
    //MARK: - Static variables
    static let shared = ProfileImageService()
    private init(){}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    //MARK: - Private variables
    private let oAuth2TokenStorage = OAuth2TokenStorage.storage
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private var isFetching = false
    private let authConfiguration = AuthConfiguration.standard
    
    //MARK: - Private Method
    func makeProfileImageRequest(username: String, token: String) -> Result<URLRequest, OAuthTokenRequestError> {
        guard let url = URL(string: "users/\(username)", relativeTo: authConfiguration.defaultBaseURL) else {
            print("❌ Ошибка: Неверный URL ProfileImageRequest")
            return.failure(.invalidBaseURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return .success(request)
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard !isFetching else {
            print("Запрос уже выполняется")
            return
        }
        
        isFetching = true
        
        guard let token = oAuth2TokenStorage.token else {
            print("❌ Ошибка: Токен отсутствует")
            completion(.failure(.missingToken))
            isFetching = false
            return
        }
        
        switch makeProfileImageRequest(username: username, token: token){
        case .failure(let error):
            print("❌ Ошибка создания запроса makeProfileImageRequest: \(error)")
            completion(.failure(.urlRequestError(error)))
            isFetching = false
            
        case .success(let request):
            let task = urlSession.objectTask(for: request){ [weak self] (result: Result<UserResult, Error>) in
                guard let self = self else { return }
                self.isFetching = false
                
                DispatchQueue.main.async {
                    print("JSON response: \(String(describing: result))")
                    switch result {
                    case .success(let userResult):
                        print("✅ Успешный ответ от API: \(userResult)")
                        
                        print("JSON profileImage: \(String(describing: userResult.profileImage))")
                        
                        guard let profileImageURL = userResult.profileImage?.small else {
                            print("❌ Ошибка: profileImage отсутствует в ответе API")
                            completion(.failure(.invalidResponseData))
                            return
                        }
                        
                        print("Полученный URL аватарки: \(profileImageURL)")
                        
                        self.avatarURL = profileImageURL
                        
                        NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL]
                        )
                        
                        self.avatarURL = profileImageURL
                        completion(.success(profileImageURL))
                        
                    case .failure(let error):
                        print("❌ Ошибка сети makeProfileImageRequest: \(error.localizedDescription)")
                        completion(.failure(.urlRequestError(error)))
                    }
                }
            }
            self.task = task
            task.resume()
        }
    }
}



