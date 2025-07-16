import Foundation

enum Constants {
    static let accessKey = "wjMXyfVMnJpxxoQ6rnlRrohVvYFJZAe0k02KdwRh7iQ"
    static let secretKey = "pFcDZ-E1oi2FRYEqzq_73Z684QHIDEvhWtcvQYPJ6So"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL?
    let authURLString: String

    static func make(with url: String) -> AuthConfiguration {
        .init(accessKey: Constants.accessKey,
              secretKey: Constants.secretKey,
              redirectURI: Constants.redirectURI,
              accessScope: Constants.accessScope,
              defaultBaseURL: Constants.defaultBaseURL,
              authURLString: url)
    }

    static let standard = make(with: WebViewConstants.unsplashAuthorizeURLString)
    static let test = make(with: WebViewConstants.unsplashAuthorizeURLString)
}
