import UIKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let avatarImageAndLogoutButtonStackView =
        AvatarImageAndLogoutButtonStackView()
    private let userNameLabel = NameLabel()
    private let tagLabel = TagLabel()
    private let statusLabel = StatusLabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        guard let token = OAuth2TokenStorage.shared.token else { return }
        profileService.fetch(token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    guard let profile = self.profileService.profileUIModel
                    else { return }
                    self.updateProfile(with: profile)
                }
            case .failure:
                print("asdadsadsadasd")
            }

        }
    }

    private func setUpUI() {
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.alignment = .leading
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 16
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
        mainStackView.addArrangedSubview(avatarImageAndLogoutButtonStackView)
        avatarImageAndLogoutButtonStackView.widthAnchor.constraint(
            equalTo: mainStackView.widthAnchor
        ).isActive = true
        mainStackView.addArrangedSubview(userNameLabel)
        mainStackView.addArrangedSubview(tagLabel)
        mainStackView.addArrangedSubview(statusLabel)
    }

    private func updateProfile(with profile: ProfileUIModel) {
        userNameLabel.text = profile.name
        tagLabel.text = profile.loginName
        statusLabel.text = profile.bio
    }
}
