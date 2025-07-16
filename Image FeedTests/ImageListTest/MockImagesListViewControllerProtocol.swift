@testable import ImageFeed
import Foundation

final class MockImagesListViewControllerProtocol: ImagesListViewControllerProtocol {
    var updateTableViewAnimatedCalled = false
    var showErrorAlertCalled = false
    var updateCellLikeStatusCalled = false
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func showErrorAlert(with title: String, message: String) {
        showErrorAlertCalled = true
    }
    
    func updateCellLikeStatus(for photoId: String) {
        updateCellLikeStatusCalled = true
    }
}
