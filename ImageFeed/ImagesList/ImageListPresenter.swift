// ImageListPresenter.swift
// Presenter for Images List screen
import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool)
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func calculateHeightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    weak var view: ImagesListViewControllerProtocol?
    private let imagesListService: ImagesListServiceProtocol
    private var imageListServiceObserver: NSObjectProtocol?
    private(set) var photos: [Photo] = []

    // MARK: - Date Formatters
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    private lazy var serverDateFormatter = ISO8601DateFormatter()

    // MARK: - Init
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
        setupObserver()
    }

    // MARK: - Lifecycle
    func viewDidLoad() {
        fetchPhotosNextPage()
    }

    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updateTableViewAnimated()
            case .failure(let error):
                print("[ImagesListPresenter:fetchPhotosNextPage] ❌ Error: \(error.localizedDescription)")
            }
        }
    }

    func changeLike(photoId: String, isLike: Bool) {
        assert(Thread.isMainThread)
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photoId, isLike: isLike) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.updateCellLikeStatus(for: photoId)
            case .failure(let error):
                self.view?.showErrorAlert(with: "Ошибка", message: "Не удалось изменить лайк.")
                print("[ImagesListPresenter:changeLike] ❌ Error: \(error.localizedDescription)")
            }
        }
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard indexPath.row < photos.count else {
            print("[ImagesListPresenter:configCell] ❌ Index out of bounds")
            return
        }
        let photo = photos[indexPath.row]
        let url = photo.thumbImageURL
        if let dateString = photo.createdAt, let date = serverDateFormatter.date(from: dateString) {
            cell.dateLabel.text = dateFormatter.string(from: date)
            cell.dateLabel.isHidden = false
        } else {
            cell.dateLabel.isHidden = true
        }
        cell.cellImage.backgroundColor = .ypDarkGray
        cell.setImage(from: url)
        cell.setIsLiked(photo.isLiked)
    }

    func calculateHeightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        guard indexPath.row < photos.count else { return 0 }
        let photo = photos[indexPath.row]
        let insets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - insets.left - insets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + insets.top + insets.bottom
    }

    // MARK: - Private Methods
    private func setupObserver() {
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard newCount > oldCount else { return }
        let newPhotos = imagesListService.photos.suffix(from: oldCount)
        photos.append(contentsOf: newPhotos)
        DispatchQueue.main.async {
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }

    deinit {
        if let observer = imageListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
