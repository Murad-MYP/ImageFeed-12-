@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view  

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Метод viewDidLoad() не был вызван у презентера")
    }
    
    func testPresenterCallsLoadRequest() {
        //given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.viewDidLoad()
        
        //then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress, "Прогресс не должен быть скрыт, когда его значение меньше 1.")
    }
    
    func testProgressHiddenWhenOne() {
        //given
        let authHelper = AuthHelper() //Dummy
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress) // return value verification
        
        //then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()

        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }

        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString), "URL должен содержать authURLString: \(configuration.authURLString)")
        XCTAssertTrue(urlString.contains(configuration.accessKey), "URL должен содержать accessKey: \(configuration.accessKey)")
        XCTAssertTrue(urlString.contains(configuration.redirectURI), "URL должен содержать redirectURI: \(configuration.redirectURI)")
        XCTAssertTrue(urlString.contains("code"), "URL должен содержать параметр 'code'")
        XCTAssertTrue(urlString.contains(configuration.accessScope), "URL должен содержать accessScope: \(configuration.accessScope)")
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test code")
    }
}
