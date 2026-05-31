import UIKit


final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    private func setUp() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.alignment = .leading
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        let avatarImageAndLogoutButtonStackView = AvatarImageAndLogoutButtonStackView()
        let userNameLabel = NameLabel()
        let tagLabel = TagLabel()
        let statusLabel = StatusLabel()
        mainStackView.addArrangedSubview(avatarImageAndLogoutButtonStackView)
        avatarImageAndLogoutButtonStackView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor).isActive = true
        mainStackView.addArrangedSubview(userNameLabel)
        mainStackView.addArrangedSubview(tagLabel)
        mainStackView.addArrangedSubview(statusLabel)
    }
}






