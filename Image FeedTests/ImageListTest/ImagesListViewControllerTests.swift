import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    
    private var viewController: ImagesListViewController!
    private var mockView: MockImagesListViewControllerProtocol!
    
    override func setUp() {
        super.setUp()
        
        mockView = MockImagesListViewControllerProtocol()
        
        viewController = ImagesListViewController()
        
        let mockPresenter = MockImagesListPresenter()
        mockPresenter.view = mockView
        viewController.testablePresenter = mockPresenter
        
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        mockView = nil
        super.tearDown()
    }
    
    private func testUpdateTableViewAnimated() {
        print("testUpdateTableViewAnimated запускается")
    }
    
    private func testShowErrorAlert() {
        print("testShowErrorAlert запускается")
    }
    
    private func testUpdateCellLikeStatus() {
        print("testUpdateCellLikeStatus запускается")
    }
}
