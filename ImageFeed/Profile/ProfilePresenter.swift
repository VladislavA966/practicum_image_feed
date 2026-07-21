import Foundation

protocol ProfileServiceProtocol {
    var profileUIModel: ProfileUIModel? { get }
}

protocol ProfileImageServiceProtocol {
    var imageUrl: String? { get }
}

protocol ProfileLogoutServiceProtocol {
    func logout()
}

extension ProfileService: ProfileServiceProtocol {}
extension ProfileImageService: ProfileImageServiceProtocol {}
extension ProfileLogoutService: ProfileLogoutServiceProtocol {}

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: ProfileUIModel)
    func updateAvatar(url: URL)
    func showLogoutAlert()
    func switchToSplashScreen()
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService: ProfileLogoutServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService
            .shared,
        logoutService: ProfileLogoutServiceProtocol = ProfileLogoutService
            .shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.logoutService = logoutService
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func viewDidLoad() {
        if let profile = profileService.profileUIModel {
            view?.updateProfileDetails(profile: profile)
        }
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }

    func didTapLogout() {
        view?.showLogoutAlert()
    }

    func confirmLogout() {
        logoutService.logout()
        view?.switchToSplashScreen()
    }

    private func updateAvatar() {
        guard
            let imageUrl = profileImageService.imageUrl,
            let url = URL(string: imageUrl)
        else { return }
        view?.updateAvatar(url: url)
    }
}
