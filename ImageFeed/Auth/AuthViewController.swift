import ProgressHUD
import UIKit

///TODO: Перенести картинку и кнопку на верстку кодом
final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?

    private let loginButton = LoginButton()
    private let logoImage = UIImageView(image: UIImage(named: "AuthLogo"))

    private let oauth2Service = OAuth2Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        view.addSubview(loginButton)
        view.addSubview(logoImage)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            loginButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            loginButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -90
            ),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        loginButton.onTap = { [weak self] in
            guard let self = self else { return }
            self.didTapLogin()
        }
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == Constants.webViewSegueIdentifier {
//            guard
//                let webViewViewController = segue.destination
//                    as? WebViewViewController
//            else {
//                assertionFailure(
//                    "Failed to prepare for \(Constants.webViewSegueIdentifier)"
//                )
//                return
//            }
//            webViewViewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }

    private func didTapLogin() {
        let webViewController = WebViewViewController()
        webViewController.delegate = self
        navigationController?.pushViewController(
            webViewController,
            animated: true
        )
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        dismiss(animated: true)

        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(
            code: code,
            { result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(_):
                    self.delegate?.didAuthenticate(self)
                case .failure(let error):
                    AlertDialogPresenter.show(vc: self, model: .loginError())
                    print("\(error)")
                }
            }
        )
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }

}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
