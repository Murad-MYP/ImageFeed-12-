import XCTest
@testable import ImageFeed

final class ProfileViewControllerTests: XCTestCase {
    
    var viewController: ProfileViewController!
    
    override func setUp() {
        super.setUp()
        viewController = ProfileViewController()
        viewController.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testUpdateProfileDetails() {
        XCTAssertNoThrow(viewController.updateProfileDetails(name: "John Doe", login: "@johndoe", bio: "Developer"))
    }
    
    func testUpdateAvatar() {
        let avatarURL = URL(string: "https://example.com/avatar.jpg")!
        XCTAssertNoThrow(viewController.updateAvatar(with: avatarURL))
    }

    func testResetToDefaultProfileData() {
        XCTAssertNoThrow(viewController.resetToDefaultProfileData())
    }
}

