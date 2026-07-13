import ProgressHUD
import UIKit

final class ImagesListViewController: UIViewController {

    private var isFirstLoadData = true

    private let imageListService = ImageListService.shared

    private var photos: [PhotoUIModel] = []

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
        UIBlockingProgressHUD.show()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImageListService.didChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFailure),
            name: ImageListService.didFaultNotification,
            object: nil
        )
        imageListService.fetchPhotosNextPage()
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
        let photo = photos[indexPath.row]
        guard let imageUrl = URL(string: photo.thumbImageURL)
        else { return }
        cell.configureCell(
            imageURL: imageUrl,
            date: dateFormatter.string(from: photo.createdAt ?? Date()),
            isLiked: photo.isLiked
        )
    }

    @objc private func updateTableViewAnimated() {
        if isFirstLoadData {
            UIBlockingProgressHUD.dismiss()
            isFirstLoadData = false
        }
        let oldCount = photos.count
        photos = imageListService.photos
        let newCount = photos.count
        imageTableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            self.imageTableView.insertRows(
                at: indexPaths,
                with: .automatic
            )
        }
    }

    @objc private func didFailure() {
        if isFirstLoadData {
            UIBlockingProgressHUD.dismiss()
            isFirstLoadData = false
        }
        AlertDialogPresenter.show(
            vc: self,
            model: AlertDialogViewModel.defaultError()
        )
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        //        let singleImageVC = SingleImageViewController()
        //        let photo = photos[indexPath.row]
        //        guard let imageUrl = URL(string: photo.largeImageURL) else { return }
        //        singleImageVC.image = UIImage(named: photo.largeImageURL)
        //        singleImageVC.modalPresentationStyle = .fullScreen
        //        present(singleImageVC, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return photos.count
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
        imageListCell.delegate = self
        return imageListCell
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imageListService.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    func didTapLikeButton(_ cell: ImageListCell) {
        print("Принт нажатия из делегата")
        guard let indexPath = imageTableView.indexPath(for: cell) else {
            return
        }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLiked: !photo.isLiked)
        { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = self.imageListService.photos
                    cell.setIsLiked(!photo.isLiked)
                    UIBlockingProgressHUD.dismiss()
                }
            case .failure:
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    AlertDialogPresenter.show(
                        vc: self,
                        model: AlertDialogViewModel.defaultError()
                    )
                }
            }
        }
    }
}
