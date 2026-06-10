import UIKit

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let avatarImageAndLogoutButtonStackView =
        AvatarImageAndLogoutButtonStackView()
    private let userNameLabel = NameLabel()
    private let tagLabel = TagLabel()
    private let statusLabel = StatusLabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        guard let profile = profileService.profileUIModel else { return }
        self.updateProfile(with: profile)
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main,
        ) {
            [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
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
        userNameLabel.text = profile.name.isEmpty ? "Не указано" : profile.name
        tagLabel.text =
            profile.loginName.isEmpty ? "Не указано" : profile.loginName
        statusLabel.text =
            (profile.bio?.isEmpty ?? true) ? "Не указано" : profile.bio
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.imageUrl,
            let url = URL(string: profileImageURL)
        else { return }
    }
}
