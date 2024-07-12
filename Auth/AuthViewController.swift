import Foundation
import UIKit
import ProgressHUD

// MARK: - AuthViewControllerDelegate Protocol
protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController
final class AuthViewController: UIViewController {

    // MARK: - Properties
    private let oAuth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
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
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        webViewVC.delegate = self
        navigationController?.pushViewController(webViewVC, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        ProgressHUD.animate()
        oAuth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let token):
                ProgressHUD.dismiss()
                print("Successfully fetched token: \(token)")
                DispatchQueue.main.async {
                    self.delegate?.authViewController(self, didAuthenticateWithCode: code)
                }
            case .failure(let error):
                ProgressHUD.dismiss()
                self.dismiss(animated: true)
                print("Failed to fetch token: \(error)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
