import UIKit

final class ProfileViewController: UIViewController {
   
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let profileImage = UIImage(named: "UserPic")
        let imageView = UIImageView(image: profileImage)
        
        let userName = UILabel()
        userName.font = UIFont.boldSystemFont(ofSize: 23)
        userName.textColor = .white
        userName.textAlignment = .left
        userName.text = "Екатерина Новикова"
        
        let loginName = UILabel()
        loginName.font = UIFont.systemFont(ofSize: 13)
        loginName.textColor = .gray
        loginName.textAlignment = .left
        loginName.text = "@ekaterina_nov"
        
        let profileInfo = UILabel()
        profileInfo.font = UIFont.systemFont(ofSize: 13)
        profileInfo.textColor = .white
        profileInfo.textAlignment = .left
        profileInfo.numberOfLines = 20
        profileInfo.text = "Hello, world!"
        
        let exitButton = UIButton(type: .custom)
        exitButton.setImage(UIImage(named: "ExitButton"), for: .normal)
        exitButton.addTarget(self, action: #selector(self.didTapExit), for: .touchUpInside)
        
        let subviews = [imageView, userName, loginName, profileInfo, exitButton]
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subview)
        }
        
        setUpConstraints(for: imageView, userName: userName, loginName: loginName, profileInfo: profileInfo, exitButton: exitButton)
    }
    
    // MARK: - Actions
    @objc private func didTapExit() {
        // Обработка нажатия кнопки выхода
    }
    
    // MARK: - Private Methods

    private func activate(_ constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            constraint.isActive = true
        }
    }
    private func setUpConstraints(for imageView: UIImageView, userName: UILabel, loginName: UILabel, profileInfo: UILabel, exitButton: UIButton) {
        let safeArea = view.safeAreaLayoutGuide
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            
            userName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            userName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            loginName.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8),
            loginName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            profileInfo.topAnchor.constraint(equalTo: loginName.bottomAnchor, constant: 8),
            profileInfo.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            
            exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            exitButton.heightAnchor.constraint(equalToConstant: 24),
            exitButton.widthAnchor.constraint(equalToConstant: 24)
        ]
        
        activate(constraints)
    }
}
