import UIKit

final class SplashViewController: UIViewController {
    let token = OAuth2TokenStorage.shared.token

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if token != nil {
            fetchProfileData()
        } else {
            performSegue(
                withIdentifier: Constants.authFlowIdentifier,
                sender: nil
            )
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
                    ///TODO: Показать сообщение об ошибке
                    print("asdadasd")
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
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.authFlowIdentifier {
            guard
                let navigationController = segue.destination
                    as? UINavigationController,
                let authViewController = navigationController.viewControllers
                    .first as? AuthViewController
            else {
                assertionFailure(
                    "Failed to prepare for \(Constants.authFlowIdentifier)"
                )
                return
            }
            authViewController.delegate = self
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        dismiss(animated: true)
        fetchProfileData()
    }
}
