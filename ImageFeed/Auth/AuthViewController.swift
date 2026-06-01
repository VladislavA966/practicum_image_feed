import UIKit

final class AuthViewController: UIViewController {
    
    @IBOutlet private weak var loginButton: UIButton!
    
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
        
    }
}


extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }

    
}
