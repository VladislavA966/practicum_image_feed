import ProgressHUD
import UIKit

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {

    var presenter: ImagesListPresenterProtocol?

    private let imageTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setUpTableView()

        let presenter = presenter ?? ImagesListPresenter()
        self.presenter = presenter
        presenter.view = self
        presenter.viewDidLoad()
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
        guard let photo = presenter?.photo(at: indexPath.row),
            let imageUrl = URL(string: photo.thumbImageURL)
        else { return }
        cell.configureCell(
            imageURL: imageUrl,
            date: photo.createdAt?.longDateString ?? "",
            isLiked: photo.isLiked
        )
    }

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
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

    func showLoading() {
        UIBlockingProgressHUD.show()
    }

    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }

    func showError() {
        AlertDialogPresenter.show(
            vc: self,
            model: AlertDialogViewModel.defaultError()
        )
    }

    func setIsLiked(at index: Int, isLiked: Bool) {
        let indexPath = IndexPath(row: index, section: 0)
        guard
            let cell = imageTableView.cellForRow(at: indexPath)
                as? ImageListCell
        else { return }
        cell.setIsLiked(isLiked)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let singleImageVC = SingleImageViewController()
        guard let imageUrl = presenter?.largeImageURL(at: indexPath.row) else {
            return
        }
        singleImageVC.fullImageURL = imageUrl
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        guard let photo = presenter?.photo(at: indexPath.row) else { return 0 }
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
        return presenter?.photosCount() ?? 0
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
        presenter?.willDisplayCell(at: indexPath.row)
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    func didTapLikeButton(_ cell: ImageListCell) {
        guard let indexPath = imageTableView.indexPath(for: cell) else {
            return
        }
        presenter?.didTapLike(at: indexPath.row)
    }
}
