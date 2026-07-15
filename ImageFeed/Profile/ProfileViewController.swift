import Kingfisher
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
        avatarImageAndLogoutButtonStackView.logoutButton.delegate = self
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
        view.backgroundColor = .ypBlack
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
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(
                UIImage.SymbolConfiguration(
                    pointSize: 70,
                    weight: .regular,
                    scale: .large
                )
            )
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        avatarImageAndLogoutButtonStackView.avatarView.avatarImageView.kf
            .indicatorType = .activity
        avatarImageAndLogoutButtonStackView.avatarView.avatarImageView.kf
            .setImage(
                with: url,
                placeholder: placeholderImage,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                ]
            )
    }
}

extension ProfileViewController: LogoutButtonDelegate {
    func logout() {
        AlertDialogPresenter.show(
            vc: self,
            model: AlertDialogViewModel.logoutAlert()
        )
    }
}

extension AlertDialogViewModel {
    static func logoutAlert() -> AlertDialogViewModel {
        AlertDialogViewModel(
            title: "Выход",
            subTitle: "Уверены что хотите выйти?",
            actionTitle: "Выйти",
            cancelTitle: "Отмена",
            action: {
                ProfileLogoutService.shared.logout()
                guard
                    let window = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                        .first
                else { return }
                window.rootViewController = SplashViewController()
            }
        )

    }

}
