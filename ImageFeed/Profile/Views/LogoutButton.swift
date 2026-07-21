import UIKit

protocol LogoutButtonDelegate: AnyObject {
    func logout()
}

final class LogoutButton: UIButton {
    private let logoutIcon = "LogoutIcon"

    weak var delegate: LogoutButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: logoutIcon), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityIdentifier = "logoutButton"
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44),
        ])
        addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }

    @objc private func handleLogout() {
        delegate?.logout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
