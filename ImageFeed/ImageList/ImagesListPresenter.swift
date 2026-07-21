import Foundation

protocol ImageListServiceProtocol {
    var photos: [PhotoUIModel] { get }
    func fetchPhotosNextPage()
    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

extension ImageListService: ImageListServiceProtocol {}

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func showError()
    func showLoading()
    func hideLoading()
    func setIsLiked(at index: Int, isLiked: Bool)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [PhotoUIModel] { get }
    func viewDidLoad()
    func photosCount() -> Int
    func photo(at index: Int) -> PhotoUIModel
    func largeImageURL(at index: Int) -> URL?
    func willDisplayCell(at index: Int)
    func didTapLike(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private let service: ImageListServiceProtocol
    private(set) var photos: [PhotoUIModel] = []
    private var isFirstLoadData = true
    private var observers: [NSObjectProtocol] = []

    init(service: ImageListServiceProtocol = ImageListService.shared) {
        self.service = service
    }

    deinit {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    func viewDidLoad() {
        view?.showLoading()
        observers.append(
            NotificationCenter.default.addObserver(
                forName: ImageListService.didChangeNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.updatePhotos()
            }
        )
        observers.append(
            NotificationCenter.default.addObserver(
                forName: ImageListService.didFaultNotification,
                object: nil,
                queue: nil
            ) { [weak self] _ in
                self?.handleFault()
            }
        )
        service.fetchPhotosNextPage()
    }

    func photosCount() -> Int {
        photos.count
    }

    func photo(at index: Int) -> PhotoUIModel {
        photos[index]
    }

    func largeImageURL(at index: Int) -> URL? {
        URL(string: photos[index].largeImageURL)
    }

    func willDisplayCell(at index: Int) {
        if index == photos.count - 1 {
            service.fetchPhotosNextPage()
        }
    }

    func didTapLike(at index: Int) {
        let photo = photos[index]
        view?.showLoading()
        service.changeLike(photoId: photo.id, isLiked: !photo.isLiked) {
            [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.service.photos
                self.view?.setIsLiked(at: index, isLiked: !photo.isLiked)
                self.view?.hideLoading()
            case .failure:
                self.view?.hideLoading()
                self.view?.showError()
            }
        }
    }

    private func updatePhotos() {
        if isFirstLoadData {
            view?.hideLoading()
            isFirstLoadData = false
        }
        let oldCount = photos.count
        photos = service.photos
        let newCount = photos.count
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }

    private func handleFault() {
        if isFirstLoadData {
            view?.hideLoading()
            isFirstLoadData = false
        }
        view?.showError()
    }
}
