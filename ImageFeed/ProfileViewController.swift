import UIKit

final class ProfileViewController: UIViewController {
    
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
        exitButton.addTarget(self, action: #selector(self.didTapExit), for: .touchUpInside)
        [profileImage, userName, loginName, profileInfo, exitButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        setUpConstraints(for: profileImage, userName: userName, loginName: loginName, profileInfo: profileInfo, exitButton: exitButton)
    }
    
    // MARK: - Actions
    @objc private func didTapExit() {
        // Обработка нажатия кнопки выхода
    }
    
    // MARK: - Private Methods
    private func setUpConstraints(for profileImage: UIImageView, 
                                  userName: UILabel,
                                  loginName: UILabel,
                                  profileInfo: UILabel,
                                  exitButton: UIButton
    ) {
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
}
