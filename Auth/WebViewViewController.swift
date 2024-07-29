import Foundation
import WebKit
import UIKit

// MARK: - WebViewViewControllerDelegate Protocol
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    func webViewViewControllerDidFail(_ vc: WebViewViewController, withError error: Error)
}

// MARK: - WebViewViewController Class
final class WebViewViewController: UIViewController {

    // MARK: - Constants
    private enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    // MARK: - Properties
    private var webView: WKWebView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    let progressView = UIProgressView(progressViewStyle: .bar)
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        loadAuthView()
        loadUIProgressView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateProgress()
            })
    }
    
    // MARK: - Private Methods
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func loadWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadUIProgressView() {
        progressView.progressTintColor = UIColor(named: "1A1B22")
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - WKNavigationDelegate Extension
extension WebViewViewController: WKNavigationDelegate {
    func webView(
                _ webView: WKWebView,
                decidePolicyFor navigationAction: WKNavigationAction,
                decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
            ) {
                if let code = Constants.code(from: navigationAction) {
                    delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
                    if nsError.domain == "WebKitErrorDomain" && nsError.code == 102 {
                        print("Ignored error: \(error.localizedDescription)")
                        return
                    }
        delegate?.webViewViewControllerDidFail(self, withError: error)
                }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
                    if nsError.domain == "WebKitErrorDomain" && nsError.code == 102 {
                        print("Ignored error: \(error.localizedDescription)")
                        return
                    }
            delegate?.webViewViewControllerDidFail(self, withError: error)
        }
}
