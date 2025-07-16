@testable import ImageFeed
import Foundation

final class MockImagesListPresenter: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    var photos: [Photo] = []
    
    func viewDidLoad() {
    }
    
    func fetchPhotosNextPage() {
        // nothing
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        // nothing
    }
    
    func changeLike(photoId: String, isLike: Bool) {
        // nothing
    }
    
    func calculateHeightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        100.0
    }
}
