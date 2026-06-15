import UIKit

final class ShareButton: UIButton {

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView?.contentMode = .scaleAspectFit
        setImage(UIImage(named: "ShareIcon"), for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
        ])
        addAction(
            UIAction { [weak self] _ in
                self?.onTap?()
            },
            for: .touchUpInside
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
