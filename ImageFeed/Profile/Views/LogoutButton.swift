import UIKit

final class LogoutButton: UIButton {
    private let logoutIcon = "LogoutIcon"

    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: logoutIcon), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])
        addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
    }
    
    @objc private func handleLogout() {
        ///TODO: Временно для дебага
        OAuth2TokenStorage.shared.clear()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
