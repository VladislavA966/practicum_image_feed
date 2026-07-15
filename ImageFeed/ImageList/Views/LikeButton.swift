import UIKit

final class LikeButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(systemName: "heart.fill"), for: .normal)
        tintColor = .white.withAlphaComponent(0.5)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setLiked(_ isLiked: Bool) {
        tintColor = isLiked ? .ypRed : .white.withAlphaComponent(0.5)
        }
}
