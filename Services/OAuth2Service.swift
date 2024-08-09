import Foundation
import UIKit

import Foundation

// MARK: - OAuth2Service Class
final class OAuth2Service {
    enum AuthServiceError: Error {
        case invalidRequest
    }
    
    // MARK: - Singleton
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard let request = NetworkService.shared.makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        print("Request: \(request)")
        
        URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let responseBody):
                    Constants.tokenStorage.token = responseBody.accessToken
                    completion(.success(responseBody.accessToken))
                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: Error - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
