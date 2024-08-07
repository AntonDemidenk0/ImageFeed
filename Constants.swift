import Foundation
import WebKit

enum Constants {
    static let accessKey = "wIzCly9JiJebxTC2tTzMPNPAbicwDwFRp0l6OQs0fkw"
    static let secretKey = "JILaw2ok-c8J9MKALGJJkoiZxxOoRIvpBmCR5RJ8x8k"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL? = URL(string: "https://api.unsplash.com")
    static let tokenStorage = OAuth2TokenStorage()
    static func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }
    static func makeOAuthTokenRequest(code: String) -> URLRequest? {
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
    static func makeProfileInfoRequest() -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        
        let profileURLString = "/me"
        guard let url = URL(string: profileURLString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        if let token = tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        request.httpMethod = "GET"
        return request
    }
    static func makeProfilePicRequest(username: String) -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        let profilePicString = "/users/\(username)"
        guard let url = URL(string: profilePicString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        var request = URLRequest(url: url)
        if let token = tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        
        request.httpMethod = "GET"
        return request
    }
    static func makePhotosRequest(page: Int) -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        let urlString = "/photos?page=\(page)"
        guard let url = URL(string: urlString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        if let token = Constants.tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        
        request.httpMethod = "GET"
        return request
    }
    static func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        let urlString = "/photos/\(photoId)/like"
        guard let url = URL(string: urlString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        if let token = Constants.tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        return request
    }
}
