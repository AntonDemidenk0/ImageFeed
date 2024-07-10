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
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        print("Request: \(request)")

        let task = URLSession.shared.fetchOAuthToken(with: request) { result in
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

    // MARK: - Private Methods
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Invalid base URL")
            return nil
        }

        let urlString = "/oauth/token"
        + "?client_id=\(Constants.accessKey)"
        + "&client_secret=\(Constants.secretKey)"
        + "&redirect_uri=\(Constants.redirectURI)"
        + "&code=\(code)"
        + "&grant_type=authorization_code"

        guard let url = URL(string: urlString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
