import Foundation

final class ProfileService {
    
    // MARK: - Enums
    
    enum ProfileServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Static Properties
    
    static let shared = ProfileService()
    
    // MARK: - Properties
    
    var profile: ProfileResult?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - Methods
    
    func fetchProfile(completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        guard let request = Constants.makeProfileInfoRequest() else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        URLSession.shared.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: Error - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
