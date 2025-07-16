import UIKit

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(with url: URL)
    func resetToDefaultProfileData()
}
