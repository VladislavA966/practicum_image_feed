import Kingfisher
import UIKit

final class ImageListCell: UITableViewCell {
    static let reuseId = "ImageListCell"

    // MARK: - Views
    private let cellImage = CellImage()

    private let gradientView = GradientView()

    private let dateLabel = DataLabel()

    private let likeButton = LikeButton()

    private let gradientLayer = CAGradientLayer()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .ypBlack
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }

    // MARK: - Setup
    private func setup() {
        contentView.addSubview(cellImage)
        contentView.addSubview(gradientView)
        contentView.addSubview(likeButton)
        gradientView.addSubview(dateLabel)
        setupGradientLayer()
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // cellImage
            cellImage.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            cellImage.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -4
            ),
            cellImage.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            cellImage.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),

            // gradientView
            gradientView.leadingAnchor.constraint(
                equalTo: cellImage.leadingAnchor
            ),
            gradientView.trailingAnchor.constraint(
                equalTo: cellImage.trailingAnchor
            ),
            gradientView.bottomAnchor.constraint(
                equalTo: cellImage.bottomAnchor
            ),
            gradientView.heightAnchor.constraint(equalToConstant: 30),

            // dateLabel
            dateLabel.topAnchor.constraint(equalTo: gradientView.topAnchor),
            dateLabel.bottomAnchor.constraint(
                equalTo: gradientView.bottomAnchor
            ),
            dateLabel.leadingAnchor.constraint(
                equalTo: gradientView.leadingAnchor,
                constant: 8
            ),
            dateLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: gradientView.trailingAnchor,
                constant: -20
            ),

            // likeButton
            likeButton.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor
            ),
            likeButton.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func setupGradientLayer() {
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
    }

    // MARK: - Configure
    func configureCell(imageURL: URL, date: String) {
        ///TODO: Настроить плейсхолдер
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: imageURL,
//                        placeholder: placeholderImage,
        )
        dateLabel.text = date
    }
    
}
