import UIKit

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?

    @IBOutlet private weak var loginButton: UIButton!

    private let oauth2Service = OAuth2Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButton()
    }

    private func configureButton() {
        loginButton.backgroundColor = .ypWhite
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        loginButton.layer.cornerRadius = 16
        loginButton.clipsToBounds = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.webViewSegueIndentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(Constants.webViewSegueIndentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        dismiss(animated: true)
        oauth2Service.fetchOAuthToken(
            code: code,
            { result in
                switch result {
                case .success(let token):
                    self.delegate?.didAuthenticate(self)
                case .failure(let error):
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

