import UIKit
import Kingfisher

final class AvatarImageAndLogoutButtonStackView: UIStackView {
    let avatarView = AvatarView()
    private let logoutButton = LogoutButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        addArrangedSubview(avatarView)
        addArrangedSubview(logoutButton)
        axis = .horizontal
        distribution = .equalSpacing
        alignment = .center
    }
  }
