import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private var app: XCUIApplication!
    
    private enum testData {
        static let fullName = ""
        static let username = ""
        static let email = ""
        static let password = ""
    }
    
    private enum Identifiers {
        static let authenticateButton = "Authenticate"
        static let unsplashWebView = "UnsplashWebView"
        static let loginButton = "Login"
        static let likeButton = "LikeButton"
        static let navBackButton = "navBackButtonWhite"
        static let logOutButton = "LogOutButton"
        static let alertPresenter = "AlertPresenter"
        static let alertYesButton = "Yes"
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testAuth() throws {
        let activeButton = app.buttons[Identifiers.authenticateButton]
        XCTAssertTrue(activeButton.waitForExistence(timeout: 5), "Кнопка 'Login' не появилась на экране")
        activeButton.tap()
        
        let webView = app.webViews[Identifiers.unsplashWebView]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не загрузился")
        
        let loginTextField = webView.descendants(matching: .textField).element
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле для логина не найдено")
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поле для пароля не найдено")
        
        loginTextField.tap()
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 10), "Клавиатура не появилась после тап по логину")
        loginTextField.typeText(testData.email)
        
        Thread.sleep(forTimeInterval: 5)
        
        passwordTextField.tap()
        XCTAssertTrue(app.keyboards.element.waitForExistence(timeout: 10), "Клавиатура не появилась после тап по паролю")
        passwordTextField.typeText(testData.password)
        
        Thread.sleep(forTimeInterval: 5)
        
        webView.swipeUp()
        
        Thread.sleep(forTimeInterval: 5)
        
        webView.buttons["Login"].tap()
        
        Thread.sleep(forTimeInterval: 5)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Ячейка не появилась — возможно, не загрузилась лента")
    }
    
    @MainActor
    func testFeed() throws {
        let table = app.tables
        
        let firstCell = table.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Первая ячейка не появилась")
        
        firstCell.swipeUp()
        
        let secondCell = table.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 10), "Вторая ячейка не появилась после скролла")
        
        let likeButton = secondCell.buttons[Identifiers.likeButton]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 10), "Кнопка лайка не найдена")
        likeButton.tap()
        
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: likeButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        likeButton.tap()
        expectation(for: existsPredicate, evaluatedWith: likeButton, handler: nil)
        waitForExpectations(timeout: 10, handler: nil)
        
        secondCell.tap()
        let fullScreenImage = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(fullScreenImage.waitForExistence(timeout: 10), "Картинка не загрузилась после перехода")
        
        fullScreenImage.pinch(withScale: 3, velocity: 1)
        fullScreenImage.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons[Identifiers.navBackButton]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Не вернулись в ленту")
    }
    
    @MainActor
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts[testData.fullName].exists)
        XCTAssertTrue(app.staticTexts[testData.username].exists)
        app.buttons[Identifiers.logOutButton].tap()
        
        app.alerts[Identifiers.alertPresenter].scrollViews.otherElements.buttons[Identifiers.alertYesButton].tap()
        
        let activeButton = app.buttons[Identifiers.authenticateButton]
        XCTAssertTrue(activeButton.waitForExistence(timeout: 5), "Экран авторизации не открылся после выхода")
    }
}
