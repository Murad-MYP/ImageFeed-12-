import UIKit

final class SplashViewController: UIViewController {
    
    //MARK: - Private lazy properties
    private lazy var splashImage: UIImageView = {
        let splashImage = UIImageView(image:UIImage(named: "Vector"))
        splashImage.translatesAutoresizingMaskIntoConstraints = false
        return splashImage
    }()
    
    //MARK: - Private properties
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage.storage
    private lazy var showErrorAlert = AlertPresenter(viewController: self)
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypLightBlack
        configureConstraintsSplashImage()
        handleAuthorizationFlow()
    }
    
    // MARK: - Override methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.validateAuthorization()
        }
    }
    
    //MARK: - Private methods
    private func configureConstraintsSplashImage(){
        view.addSubview(splashImage)
        
        NSLayoutConstraint.activate([
            splashImage.widthAnchor.constraint(equalToConstant: 72),
            splashImage.heightAnchor.constraint(equalToConstant: 75),
            splashImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 228),
            splashImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
    
    private func handleAuthorizationFlow() {
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            validateAuthorization()
        }
    }
    
    private func validateAuthorization(){
        if OAuth2TokenStorage.storage.token != nil {
            print("Токен прошел авторизацию")
            switchToTabBarController()
        } else {
            print("Токен отсутствует, переход на AuthViewController")
            let authViewController = AuthViewController()
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        print("Переход на \(TabBarController.identifier)")
        
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                let username = profile.userName
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in
                    print("fetchProfileImageURL завершился с результатом: \(result)")
                }
                self.switchToTabBarController()
            case .failure(let error):
                print("❌ Ошибка при загрузке профиля: \(error)")
                let alertModel = AlertModel(title: "Ошибка",
                                            message: "Не удалось загрузить профиль: \(error.localizedDescription)",
                                            buttonText: "OK",
                                            completion: nil,
                                            secondButtonText: nil,
                                            secondButtonCompletion: nil)
                showErrorAlert.showAlert(with: alertModel)
            }
        }
    }
}

//MARK: - Extension
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else {
            return
        }
        fetchProfile(token: token)
    }
}
