// ImagesListService.swift
// Service for loading and managing paginated photo list
import Foundation

final class ImagesListService: ImagesListServiceProtocol {
    // MARK: - Public Properties
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []

    // MARK: - Private Properties
    private var lastLoadedPage: Int?
    private var isFetching = false
    private let oAuth2TokenStorage = OAuth2TokenStorage.storage
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?

    // MARK: - Init
    private init() {}

    // MARK: - Public Methods
    func fetchPhotosNextPage(completion: ((Result<[Photo], Error>) -> Void)? = nil) {
        assert(Thread.isMainThread)
        guard !isFetching else { return }
        isFetching = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let token = oAuth2TokenStorage.token else {
            print("[ImagesListService:fetchPhotosNextPage] ❌ Missing token")
            isFetching = false
            return
        }
        task?.cancel()
        switch makePhotosNextPage(token: token) {
        case .failure(let error):
            print("[ImagesListService:fetchPhotosNextPage] ❌ Request creation error: \(error)")
            isFetching = false
            completion?(.failure(error))
        case .success(let request):
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
                guard let self = self else { return }
                self.isFetching = false
                switch result {
                case .success(let photoResults):
                    let newPhotos = Photo.makeArray(from: photoResults)
                    let uniquePhotos = newPhotos.filter { newPhoto in
                        !self.photos.contains { $0.id == newPhoto.id }
                    }
                    DispatchQueue.main.async {
                        self.photos.append(contentsOf: uniquePhotos)
                        self.lastLoadedPage = nextPage
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                        completion?(.success(uniquePhotos))
                    }
                case .failure(let error):
                    print("[ImagesListService:fetchPhotosNextPage] ❌ Network error: \(error)")
                    completion?(.failure(error))
                }
            }
            self.task = task
            task.resume()
        }
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard !isFetching else {
            print("[ImagesListService:changeLike] Request already in progress")
            return
        }
        isFetching = true
        guard let token = oAuth2TokenStorage.token else {
            print("[ImagesListService:changeLike] ❌ Missing token")
            completion(.failure(.missingToken))
            isFetching = false
            return
        }
        switch makeChangeLikeRequest(photoId: photoId, token: token, isLiked: isLike) {
        case .failure(let error):
            print("[ImagesListService:changeLike] ❌ Request creation error: \(error)")
            completion(.failure(.urlRequestError(error)))
            isFetching = false
        case .success(let request):
            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResult, Error>) in
                guard let self = self else { return }
                self.isFetching = false
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("[ImagesListService:changeLike] ❌ Network error: \(error.localizedDescription)")
                        completion(.failure(.urlRequestError(error)))
                    case .success:
                        if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                            var photo = self.photos[index]
                            photo.isLiked.toggle()
                            self.photos[index] = photo
                        }
                        completion(.success(()))
                    }
                }
            }
            task.resume()
        }
    }

    func cleanImageList() {
        photos.removeAll()
        lastLoadedPage = nil
    }

    // MARK: - Private Methods
    private func makePhotosNextPage(token: String) -> Result<URLRequest, OAuthTokenRequestError> {
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let baseURL = Constants.defaultBaseURL else {
            print("[ImagesListService:makePhotosNextPage] ❌ baseURL missing")
            return .failure(.invalidRequest)
        }
        let photosPath = baseURL.appendingPathComponent("photos")
        var urlComponents = URLComponents(url: photosPath, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents?.url else {
            print("[ImagesListService:makePhotosNextPage] ❌ Invalid URL")
            return .failure(.invalidRequest)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return .success(request)
    }

    private func makeChangeLikeRequest(photoId: String, token: String, isLiked: Bool) -> Result<URLRequest, OAuthTokenRequestError> {
        guard let url = URL(string: "photos/\(photoId)/like", relativeTo: Constants.defaultBaseURL) else {
            print("[ImagesListService:makeChangeLikeRequest] ❌ Invalid URL")
            return .failure(.invalidBaseURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLiked ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return .success(request)
    }
}
