import UIKit

final class NameLabel: UILabel {
    private let nameText = "Екатерина Новикова"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = .ypWhite
        self.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        self.text = nameText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
