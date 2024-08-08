import Foundation

final class ProfileImageService {
    
    // MARK: - Enums
    enum ProfileImageError: Error {
        case invalidRequest
    }
    
    // MARK: - Static Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    
    // MARK: - Properties
    private (set) var avatarURL: String?
    
    // MARK: - Initializers
    private init() {}
    
    // MARK: - Public Methods
    func fetchProfileImageURL(_ completion: @escaping (Result<String, Error>) -> Void) {
        guard let username = ProfileService.shared.profile?.username else {
            print("[ProfileImageService.fetchProfileImageURL]: Error - Username is nil")
            completion(.failure(ProfileImageError.invalidRequest))
            return
        }
        
        guard let request = NetworkService.shared.makeProfilePicRequest(username: username) else {
            print("[ProfileImageService.fetchProfileImageURL]: Error - Invalid request")
            completion(.failure(ProfileImageError.invalidRequest))
            return
        }
        
        URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let userResult):
                    self.avatarURL = userResult.profileImage?.small
                    if let avatarURL = self.avatarURL {
                        completion(.success(avatarURL))
                        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
                    } else {
                        print("[ProfileImageService.fetchProfileImageURL]: Error - Invalid request")
                        completion(.failure(ProfileImageError.invalidRequest))
                    }
                case .failure(let error):
                    print("[ProfileImageService.fetchProfileImageURL]: Error - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func resetImageURL() {
        self.avatarURL = nil
    }
}
