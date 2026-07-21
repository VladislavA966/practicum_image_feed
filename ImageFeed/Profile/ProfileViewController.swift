import Kingfisher
import UIKit

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?

    private let avatarImageAndLogoutButtonStackView =
        AvatarImageAndLogoutButtonStackView()
    private let userNameLabel = NameLabel()
    private let tagLabel = TagLabel()
    private let statusLabel = StatusLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()

        let presenter = presenter ?? ProfilePresenter()
        self.presenter = presenter
        presenter.view = self

        avatarImageAndLogoutButtonStackView.logoutButton.delegate = self
        presenter.viewDidLoad()
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
        userNameLabel.accessibilityIdentifier = "profileName"
        tagLabel.accessibilityIdentifier = "profileLogin"
        mainStackView.addArrangedSubview(userNameLabel)
        mainStackView.addArrangedSubview(tagLabel)
        mainStackView.addArrangedSubview(statusLabel)
    }

    func updateProfileDetails(profile: ProfileUIModel) {
        userNameLabel.text = profile.name.isEmpty ? "Не указано" : profile.name
        tagLabel.text =
            profile.loginName.isEmpty ? "Не указано" : profile.loginName
        statusLabel.text =
            (profile.bio?.isEmpty ?? true) ? "Не указано" : profile.bio
    }

    func updateAvatar(url: URL) {
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

    func showLogoutAlert() {
        AlertDialogPresenter.show(
            vc: self,
            model: AlertDialogViewModel.logoutAlert { [weak self] in
                self?.presenter?.confirmLogout()
            }
        )
    }

    func switchToSplashScreen() {
        guard
            let window = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first
        else { return }
        window.rootViewController = SplashViewController()
    }
}

extension ProfileViewController: LogoutButtonDelegate {
    func logout() {
        presenter?.didTapLogout()
    }
}

extension AlertDialogViewModel {
    static func logoutAlert(action: @escaping () -> Void) -> AlertDialogViewModel {
        AlertDialogViewModel(
            title: "Выход",
            subTitle: "Уверены что хотите выйти?",
            actionTitle: "Выйти",
            cancelTitle: "Отмена",
            action: action
        )
    }
}
