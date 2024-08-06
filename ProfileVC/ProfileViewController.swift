import UIKit
import WebKit
import SwiftKeychainWrapper
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    var profile: ProfileResult? {
        didSet {
            if isViewLoaded {
                updateProfileDetails()
                updateAvatar()
            }
        }
    }
    
    private let profileImage: UIImageView = {
        let image = UIImage(named: "UserPic")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private let userName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = .white
        label.textAlignment = .left
        label.text = "Екатерина Новикова"
        return label
    }()
    
    private let loginName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .left
        label.text = "@ekaterina_nov"
        return label
    }()
    
    private let profileInfo: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 20
        label.text = "Hello, world!"
        return label
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ExitButton"), for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObserver()
        updateAvatar()
        updateProfileDetails()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        exitButton.addTarget(self, action: #selector(didTapExit), for: .touchUpInside)
        [profileImage, userName, loginName, profileInfo, exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setUpConstraints(for: profileImage, userName: userName, loginName: loginName, profileInfo: profileInfo, exitButton: exitButton)
    }
    
    private func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    
    // MARK: - Actions
    
    @objc private func didTapExit() {
        showLogoutAlert()
     }
    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Private Methods
    
    private func setUpConstraints(for profileImage: UIImageView,
                                  userName: UILabel,
                                  loginName: UILabel,
                                  profileInfo: UILabel,
                                  exitButton: UIButton) {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            
            userName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            
            loginName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            loginName.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            
            profileInfo.topAnchor.constraint(equalTo: loginName.bottomAnchor, constant: 8),
            profileInfo.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func updateProfileDetails() {
           guard let profile = profile else { return }
           print("Updating profile details with: \(profile)")
           loginName.text = profile.username
           let firstName = profile.first_name ?? ""
           let lastName = profile.last_name ?? ""
           userName.text = "\(firstName) \(lastName)"
           profileInfo.text = profile.bio ?? ""
       }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            profileImage.image = UIImage(named: "NoAvatarUser")
            profileImage.layer.cornerRadius = 35
            profileImage.layer.masksToBounds = true
            return
        }
        profileImage.kf.setImage(with: url)
        profileImage.layer.cornerRadius = 35
        profileImage.layer.masksToBounds = true
    }
}
