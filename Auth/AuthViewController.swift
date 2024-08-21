import Foundation
import UIKit

// MARK: - AuthViewControllerDelegate Protocol
protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController
final class AuthViewController: UIViewController {
    
    // MARK: - Properties
    private let oAuth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    let splashVC = SplashViewController()
    
    private let authImageView: UIImageView = {
        let authImage = UIImage(named: "Logo")
        let imageView = UIImageView(image: authImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor(named: "1A1B22"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "Authenticate"
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "1A1B22")
        setupViews()
        setUpConstraints()
        configureBackButton()
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        view.addSubview(authImageView)
        view.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }
    
    private func setUpConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            authImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            authImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            authImageView.heightAnchor.constraint(equalToConstant: 60),
            authImageView.widthAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -90),
            loginButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            loginButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "NavBackButton")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "NavBackButton")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "1A1B22")
    }
    
    // MARK: - Actions
    @objc private func didTapLogin() {
        let webViewVC = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewVC.presenter = webViewPresenter
        webViewPresenter.view = webViewVC
        webViewVC.delegate = self
        navigationController?.pushViewController(webViewVC, animated: true)
    }
    
    // MARK: - Error Alert
    func showLoginErrorAlert() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alertController.addAction(okAction)

        if let rootController = UIApplication.shared.windows.first?.rootViewController {
            var topController = rootController
            while let presented = topController.presentedViewController {
                topController = presented
            }
            topController.present(alertController, animated: true, completion: nil)
        }
    }
}
// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let token):
                print("Successfully fetched token: \(token)")
                DispatchQueue.main.async {
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                    vc.dismiss(animated: true)
                }
            case .failure(let error):
                print("Failed to fetch token: \(error)")
                self.navigationController?.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.navigationController?.topViewController is AuthViewController {
                        self.showLoginErrorAlert()
                    }
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    func webViewViewControllerDidFail(_ vc: WebViewViewController, withError error: Error) {
        UIBlockingProgressHUD.dismiss()
        print("WebView failed with error: \(error.localizedDescription)")
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.navigationController?.topViewController is AuthViewController {
                self.showLoginErrorAlert()
            }
        }
    }
}
