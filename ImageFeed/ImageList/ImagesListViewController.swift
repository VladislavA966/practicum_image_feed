import UIKit

final class ImagesListViewController: UIViewController {

    private let photosName: [String] = Array(0..<20).map { "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    private let imageTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setUpTableView()
    }

    private func setUpTableView() {
        view.addSubview(imageTableView)
        imageTableView.delegate = self
        imageTableView.dataSource = self
        imageTableView.backgroundColor = .ypBlack
        imageTableView.translatesAutoresizingMaskIntoConstraints = false
        imageTableView.register(
            ImageListCell.self,
            forCellReuseIdentifier: ImageListCell.reuseId
        )
        imageTableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        NSLayoutConstraint.activate([
            imageTableView.topAnchor.constraint(equalTo: view.topAnchor),
            imageTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            imageTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

        ])
    }

    private func setUpCell(for cell: ImageListCell, with indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]

        guard let image = UIImage(named: imageName) else { return }

        cell.configureCell(
            image: image,
            date: dateFormatter.string(from: Date())
        )

    }

}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.image = UIImage(named: photosName[indexPath.row])
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let imageName = photosName[indexPath.row]
        guard let image = UIImage(named: imageName) else { return 0 }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / image.size.width
        return image.size.height * scale + imageInsets.top + imageInsets.bottom
    }

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageListCell.reuseId,
            for: indexPath
        )
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        setUpCell(for: imageListCell, with: indexPath)
        return imageListCell
    }

}
