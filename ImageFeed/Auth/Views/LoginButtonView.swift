import UIKit

final class LoginButton: UIButton {

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        setTitle("Войти", for: .normal)
        setTitleColor(.ypBlack, for: .normal)
        backgroundColor = .ypWhite
        titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        layer.cornerRadius = 16
        clipsToBounds = true

        addAction(
            UIAction { [weak self] _ in
                self?.onTap?()
            },
            for: .touchUpInside
        )
    }
}
