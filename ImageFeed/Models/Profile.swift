import Foundation

struct Profile {
    let userName: String
    let firstName: String
    let lastName: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.userName = profileResult.username
        self.firstName = profileResult.firstName
        self.lastName = profileResult.lastName
        self.name = "\(profileResult.firstName) \(profileResult.lastName)"
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}
