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
}
