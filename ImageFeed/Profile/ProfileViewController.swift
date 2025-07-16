import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    private lazy var presenter = ProfilePresenter(view: self)
    
    // MARK: - Private properties
    private lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImage(named: "Photo")
        let avatarImageView = UIImageView(image: avatarImage)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        return avatarImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        nameLabel.textAlignment = .left
        nameLabel.textColor = .ypWhite
        return nameLabel
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textAlignment = .left
        loginNameLabel.textColor = .ypLightGray
        return loginNameLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .ypWhite
        return descriptionLabel
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton(type: .custom)
        if let exitImage = UIImage(named: "Exit"){
            logoutButton.setImage(exitImage, for: .normal)
        }
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.tintColor = .ypCoral
        return logoutButton
    }()
    
    private lazy var errorAlert = AlertPresenter(viewController: self)
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
#if DEBUG
        setupDebugAccessibilityIdentifier()
#endif
    }
    
    //MARK: - Override methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    // MARK: - Private methods
    private func setupUI(){
        configureConstraintsAvatarImageView()
        configureConstraintsNameLabel()
        configureConstraintsLoginNameLabel()
        configureConstraintsDescriptionLabel()
        configureConstraintsLogoutButton()
    }
    
    private func configureConstraintsAvatarImageView(){
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureConstraintsNameLabel(){
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureConstraintsLoginNameLabel(){
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureConstraintsDescriptionLabel(){
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureConstraintsLogoutButton(){
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            nameLabel.text = name
            loginNameLabel.text = login
            descriptionLabel.text = bio
        }
    }
    
    func updateAvatar(with url: URL) {
        avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "PlaceholderAvatar"))
    }
    
    func resetToDefaultProfileData() {
        let cleanURL: URL? = nil
        self.avatarImageView.kf.setImage(with: cleanURL, placeholder: UIImage(named: "PlaceholderAvatar"))
        
        DispatchQueue.main.async {
            self.avatarImageView.image = UIImage(named: "Photo")
            self.nameLabel.text = "Екатерина Новикова"
            self.loginNameLabel.text = "@ekaterina_nov"
            self.descriptionLabel.text = "Hello, world!"
        }
    }
    
    //MARK: - Action
    @objc private func didTapLogoutButton() {
        print("Logout button tapped")
        let alertmodel = AlertModel(title: "Пока, пока!",
                                    message: "Уверены что хотите выйти?",
                                    buttonText: "Нет",
                                    completion: nil,
                                    secondButtonText: "Да",
                                    secondButtonCompletion: {
            self.presenter.logoutTapped()
        })
        errorAlert.showAlert(with: alertmodel)
    }
    
#if DEBUG
    private func setupDebugAccessibilityIdentifier(){
        logoutButton.accessibilityIdentifier = "LogOutButton"
    }
#endif
}

#if DEBUG
extension ProfileViewController {
    func getNameLabelText() -> String? {
        return nameLabel.text
    }
    
    func getLoginNameLabelText() -> String? {
        return loginNameLabel.text
    }
    
    func getDescriptionLabelText() -> String? {
        return descriptionLabel.text
    }
    
    func getAvatarImage() -> UIImage? {
        return avatarImageView.image
    }
}
#endif
