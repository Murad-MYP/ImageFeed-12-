import UIKit

final class AuthViewController: UIViewController {
    // MARK: - Delegate
    weak var delegate: AuthViewControllerDelegate?

    // MARK: - UI Elements
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "auth_screen_logo"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setTitleColor(.ypLightBlack, for: .normal)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
#if DEBUG
        button.accessibilityIdentifier = "Authenticate"
#endif
        return button
    }()

    // MARK: - Private Properties
    private let oauth2Service = OAuth2Service.shared
    private lazy var alertPresenter = AlertPresenter(viewController: self)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypLightBlack
        navigationItem.hidesBackButton = true
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        view.addSubview(logoImageView)
        view.addSubview(loginButton)
        setupConstraints()
        setupBackButton()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),

            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func setupBackButton() {
        let backImage = UIImage(named: "navBackButton")
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "#1A1B22")
    }

    // MARK: - Actions
    @objc private func didTapLoginButton() {
        let webViewVC = WebViewViewController()
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        presenter.view = webViewVC
        webViewVC.presenter = presenter
        webViewVC.delegate = self

        let navVC = UINavigationController(rootViewController: webViewVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()

            switch result {
            case .success(let token):
                OAuth2TokenStorage.storage.token = token
                delegate?.didAuthenticate(self)
            case .failure:
                let alert = AlertModel(
                    title: "Что-то пошло не так(",
                    message: "Не удалось войти в систему",
                    buttonText: "OK"
                )
                alertPresenter.showAlert(with: alert)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
