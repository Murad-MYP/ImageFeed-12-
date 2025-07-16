import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func authURL() -> URL? // ← добавлено в протокол
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    
    private let config: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.config = configuration
    }

    func authRequest() -> URLRequest? {
        authURL().map { URLRequest(url: $0) }
    }

    // 🔓 Сделали internal вместо private
    func authURL() -> URL? {
        var components = URLComponents(string: config.authURLString)
        components?.queryItems = [
            .init(name: "client_id", value: config.accessKey),
            .init(name: "redirect_uri", value: config.redirectURI),
            .init(name: "response_type", value: "code"),
            .init(name: "scope", value: config.accessScope)
        ]
        return components?.url
    }

    func code(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.path == "/oauth/authorize/native" else { return nil }

        return components.queryItems?.first(where: { $0.name == "code" })?.value
    }
}
