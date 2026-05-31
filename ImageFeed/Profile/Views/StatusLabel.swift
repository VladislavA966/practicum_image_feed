import UIKit

final class StatusLabel: UILabel {
    private let statusText = "Hello, world!"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = .ypWhite
        self.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.text = statusText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
