import UIKit
import ProgressHUD
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public properties
    var image: Photo? {
        didSet {
            guard isViewLoaded, let image = image else { return }
            updateImage(from: image.largeImageURL)
        }
    }
    
    // MARK: - Private properties
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.delegate = self
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.minimumZoomScale = 1.0
        scroll.maximumZoomScale = 3.0
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Sharing"), for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Backward"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var errorAlert = AlertPresenter(viewController: self)
    private var initialZoomScale: CGFloat = 1.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypLightBlack
        setupViewConstraints()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapImage))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)
        imageView.isUserInteractionEnabled = true
        
        if let image = image {
            updateImage(from: image.largeImageURL)
        }
    }
    
    // MARK: - Private Methods
    private func setupViewConstraints() {
        view.addSubview(scrollView)
        view.addSubview(shareButton)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11)
        ])
        
#if DEBUG
        backButton.accessibilityIdentifier = "navBackButtonWhite"
#endif
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(hScale, vScale)
        
        if scale > 0 {
            scrollView.setZoomScale(scale, animated: false)
            initialZoomScale = scale // Обновляем начальный масштаб для двойного тапа
        }
        
        scrollView.layoutIfNeeded()
        centerImageIfNeeded()
    }
    
    private func centerImageIfNeeded() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        let x = max((visibleRectSize.width - newContentSize.width) / 2, 0)
        let y = max((visibleRectSize.height - newContentSize.height) / 2, 0)
        scrollView.contentInset = UIEdgeInsets(top: y, left: x, bottom: y, right: x)
    }
    
    private func updateImage(from url: URL) {
        UIBlockingProgressHUD.show()
        
        let placeholderImage = UIImage(named: "placeholder")
        imageView.contentMode = .center
        
        imageView.kf.setImage(with: url, placeholder: placeholderImage) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let imageResult):
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.image = imageResult.image
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure(let error):
                let alertModel = AlertModel(
                    title: "Ошибка",
                    message: "Не удалось загрузить изображение",
                    buttonText: "Ok",
                    completion: { self.navigationController?.popViewController(animated: true) },
                    secondButtonText: nil,
                    secondButtonCompletion: nil
                )
                
                self.errorAlert.showAlert(with: alertModel)
                print("Ошибка загрузки изображения: \(error)")
            }
        }
    }
    
    @objc private func didDoubleTapImage() {
        scrollView.setZoomScale(initialZoomScale, animated: true)
        centerImageIfNeeded()
    }
    
    @objc private func didTapBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShareButton(_ sender: Any) {
        guard let imageToShare = imageView.image else { return }
        let share = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        present(share, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageIfNeeded()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageIfNeeded()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SingleImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
