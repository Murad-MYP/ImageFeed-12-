import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // Ключ для хранения токена в Keychain
    private let tokenKey = "oauthToken"
    
    // Синглтон для доступа к хранилищу токена
    static let storage = OAuth2TokenStorage()
    
    // Токен OAuth2 с геттером и сеттером для Keychain
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    // Удаляет все ключи из Keychain (можно изменить, если нужна только очистка токена)
    func clearToken() {
        let removed = KeychainWrapper.standard.removeAllKeys()
        print("Удаление токена из Keychain: \(removed ? "успешно" : "не удалось")")
    }
    
    // Приватный конструктор для синглтона
    private init() { }
}

