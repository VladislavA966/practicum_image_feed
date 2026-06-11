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

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(
                withIdentifier: Constants.tabBarViewController
            )

        window.rootViewController = tabBarController
    }

    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard
            let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController
        else {
            assertionFailure("Invalid view controller configuration")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        dismiss(animated: true)
        fetchProfileData()
    }
}
