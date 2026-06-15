import UIKit

private let imageName = "SplashScreenIcon"

final class SplashViewController: UIViewController {
    let token = OAuth2TokenStorage.shared.token

    let splashImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        view.addSubview(splashImageView)
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            splashImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
        ])

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if token != nil {
            fetchProfileData()
        } else {
            presentAuthViewController()
        }
    }

    private func fetchProfileData() {
        UIBlockingProgressHUD.dismiss()
        DispatchQueue.main.async {
            ProfileService.shared.fetch { result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profile):
                    ProfileImageService.shared.fetchProfileImageUrl(
                        name: profile.name
                    ) { _ in }
                    self.switchToTabBarController()
                case .failure(_):
                    AlertDialogPresenter.show(vc: self, model: .defaultError())
                    break
                }
            }
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        window.rootViewController = TabBarViewController()
    }

    private func presentAuthViewController() {
        let authVC = AuthViewController()
        authVC.delegate = self
        let navVC = UINavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        dismiss(animated: true)
        fetchProfileData()
    }
}
