import Foundation
import UIKit

// MARK: - SplashViewController
final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let splashImageView: UIImageView = {
        let splashImage = UIImage(named: "LaunchScreen")
        let imageView = UIImageView(image: splashImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "1A1B22")
        view.addSubview(splashImageView)
        activateConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
            if tokenStorage.token != nil {
                fetchUserProfile()
            } else {
                let authViewController = AuthViewController()
                let navigationController = UINavigationController(rootViewController: authViewController)
                navigationController.modalPresentationStyle = .fullScreen
                authViewController.delegate = self
                self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    private func switchToTabBarController(with profile: ProfileResult?) {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
            fatalError("Could not instantiate TabBarViewController from storyboard")
        }

        if let profileVC = tabBarController.viewControllers?.first(where: { $0 is ProfileViewController }) as? ProfileViewController {
            profileVC.profile = profile
        }
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchUserProfile() {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("Profile fetched successfully: \(profile)")
                self.switchToTabBarController(with: profile)
                self.fetchProfileImage()
            case .failure(let error):
                print("Failed to fetch profile: \(error)")
                self.switchToTabBarController(with: nil)
            }
        }
    }
    private func fetchProfileImage() {
        ProfileImageService.shared.fetchProfileImageURL { result in
            switch result {
            case .success(let imageURL):
                print("Profile image URL: \(imageURL)")
            case .failure(let error):
                print("Failed to fetch profile image URL: \(error)")
            }
        }
    }
    private func activateConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
        ])
    }
}

// MARK: - Navigation
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                fatalError("Failed to prepare for \(ShowAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchUserProfile()
            case .failure:
                break
            }
        }
    }
}
