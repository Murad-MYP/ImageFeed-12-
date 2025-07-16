import Foundation

final class ProfileService {
    
    //MARK: - Private variables
    private let oAuth2TokenStorage = OAuth2TokenStorage.storage
    private let urlSession = URLSession.shared
    private let authConfiguration = AuthConfiguration.standard
    private var task: URLSessionTask?
    private var isFetching = false
    
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    //MARK: - Private Method
    func makeProfileRequest(token: String) -> Result<URLRequest, OAuthTokenRequestError> {
        
        guard let url = URL(string: "me", relativeTo: authConfiguration.defaultBaseURL) else {
            print("❌ Ошибка: Неверный URL ProfileRequest")
            return.failure(.invalidBaseURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return .success(request)
    }
    
    func fetchProfile(completion: @escaping (Result<Profile, NetworkError>) -> Void) -> Void {
        guard !isFetching else {
            print("Запрос уже выполняется")
            return
        }
        
        isFetching = true
        
        guard let token = oAuth2TokenStorage.token else {
            print("❌ Ошибка: Токен отсутствует")
            completion(.failure(NetworkError.missingToken))
            isFetching = false
            return
        }
        
        switch makeProfileRequest(token: token){
        case .failure(let error):
            print("❌ Ошибка создания запроса makeProfileRequest: \(error)")
            isFetching = false
        case .success(let request):
            let task = urlSession.objectTask(for: request){ [weak self] (result: Result<ProfileResult, Error>) in
                guard let self = self else { return }
                self.isFetching = false
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profileResult):
                        let profile = Profile(from: profileResult)
                        self.profile = profile
                        completion(.success(profile))
                        
                        print("Профиль загружен, запрашиваем аватар...")
                        ProfileImageService.shared.fetchProfileImageURL(username: profile.userName) { result in
                            switch result {
                            case .success(let avatarURL):
                                print("✅ Аватар успешно загружен: \(avatarURL)")
                            case .failure(let error):
                                print("❌ Ошибка загрузки аватара: \(error)")
                            }
                        }
                        
                    case .failure(let error):
                        print("❌ Ошибка сети makeProfileRequest: \(error.localizedDescription)")
                        completion(.failure(.urlRequestError(error)))
                    }
                }
            }
            self.task = task
            task.resume()
        }
    }
}
