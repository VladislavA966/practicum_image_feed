import UIKit

final class ImageListCell: UITableViewCell {

    @IBOutlet private weak var cellImage: UIImageView!

    @IBOutlet private weak var gradientView: UIView!

    @IBOutlet private weak var dateLabel: UILabel!

    private let gradientLayer = CAGradientLayer()

    static let reuseId = "ImageListCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        cellImage.contentMode = .scaleAspectFill
        setUpGradientView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.layoutIfNeeded()
        gradientLayer.frame = gradientView.bounds
    }
    
    func configureCell(image: UIImage, date: String) {
        cellImage.image = image
        dateLabel.text = date
    }

    private func setUpGradientView() {
        let baseColor = UIColor(
            red: 26 / 255,
            green: 27 / 255,
            blue: 34 / 255,
            alpha: 1.0
        )
        gradientLayer.colors = [
            baseColor.withAlphaComponent(0.0).cgColor,
            baseColor.withAlphaComponent(0.8).cgColor,
        ]

        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
        ]
        gradientView.layer.masksToBounds = true
    }

}
