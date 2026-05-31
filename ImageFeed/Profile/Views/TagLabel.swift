import UIKit

final class TagLabel: UILabel {
    private let tagText = "@ekaterina_nov"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = .ypGray
        self.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        self.text = tagText
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

