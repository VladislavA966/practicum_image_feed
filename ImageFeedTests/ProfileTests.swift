@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsUpdateProfileDetails() {
        let profile = ProfileUIModel(
            username: "user",
            name: "Test Name",
            loginName: "@user",
            bio: "bio"
        )
        let profileService = ProfileServiceStub(profileUIModel: profile)
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: ProfileImageServiceStub(),
            logoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.viewDidLoad()

        XCTAssertTrue(viewController.updateProfileDetailsCalled)
    }

    func testDidTapLogoutShowsAlert() {
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profileUIModel: nil),
            profileImageService: ProfileImageServiceStub(),
            logoutService: ProfileLogoutServiceSpy()
        )
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.didTapLogout()

        XCTAssertTrue(viewController.showLogoutAlertCalled)
    }

    func testConfirmLogoutCallsLogoutService() {
        let logoutService = ProfileLogoutServiceSpy()
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(
            profileService: ProfileServiceStub(profileUIModel: nil),
            profileImageService: ProfileImageServiceStub(),
            logoutService: logoutService
        )
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.confirmLogout()

        XCTAssertTrue(logoutService.logoutCalled)
        XCTAssertTrue(viewController.switchToSplashScreenCalled)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {}

    func confirmLogout() {}
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    var switchToSplashScreenCalled = false

    func updateProfileDetails(profile: ProfileUIModel) {
        updateProfileDetailsCalled = true
    }

    func updateAvatar(url: URL) {
        updateAvatarCalled = true
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }

    func switchToSplashScreen() {
        switchToSplashScreenCalled = true
    }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    let profileUIModel: ProfileUIModel?

    init(profileUIModel: ProfileUIModel?) {
        self.profileUIModel = profileUIModel
    }
}

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var imageUrl: String?
}

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled = false

    func logout() {
        logoutCalled = true
    }
}
