import Foundation
import WebKit
import UIKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

// MARK: - WebViewViewControllerDelegate Protocol
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
    func webViewViewControllerDidFail(_ vc: WebViewViewController, withError error: Error)
}

// MARK: - WebViewViewController Class
final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {


    // MARK: - Properties
    var presenter: WebViewPresenterProtocol?
    private var webView: WKWebView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    let progressView = UIProgressView(progressViewStyle: .bar)
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        loadUIProgressView()
        webView.navigationDelegate = self
        webView.accessibilityIdentifier = "UnsplashWebView"
        presenter?.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(progressView)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            presenter?.didUpdateProgressValue(webView.estimatedProgress)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods

    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
                return presenter?.code(from: url)
            }
            return nil
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

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

// MARK: - WKNavigationDelegate Extension
extension WebViewViewController: WKNavigationDelegate {
    func webView(
                _ webView: WKWebView,
                decidePolicyFor navigationAction: WKNavigationAction,
                decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
            ) {
                if let code = code(from: navigationAction) {
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
