import Foundation
import UIKit

struct ProfileResult: Codable {
    let username: String?
    let first_name: String?
    let last_name: String?
    let bio: String?
}

struct UserResult: Codable {
    let profileImage: ProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}
