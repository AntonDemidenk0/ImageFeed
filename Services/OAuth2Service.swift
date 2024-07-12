import Foundation

// MARK: - OAuth2Service Class
final class OAuth2Service {

    // MARK: - Singleton
    static let shared = OAuth2Service()
    private init() {}

    // MARK: - Properties
    private let tokenStorage = OAuth2TokenStorage()

    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = Constants.makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        print("Request: \(request)")

        let task = URLSession.shared.fetchOAuthToken(with: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let responseBody):
                print("Response body: \(responseBody)")
                self.tokenStorage.token = responseBody.accessToken
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                print("Network error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
