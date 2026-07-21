@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    private func makePhoto(id: String = "1", isLiked: Bool = false)
        -> PhotoUIModel
    {
        PhotoUIModel(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb",
            largeImageURL: "https://example.com/large",
            isLiked: isLiked
        )
    }

    func testViewControllerCallsViewDidLoad() {
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testViewDidLoadFetchesPhotos() {
        let service = ImageListServiceSpy()
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(service.fetchCallCount, 1)
        XCTAssertTrue(view.showLoadingCalled)
    }

    func testDidChangeUpdatesPhotosAndView() {
        let service = ImageListServiceSpy(photos: [makePhoto()])
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view
        presenter.viewDidLoad()

        NotificationCenter.default.post(
            name: ImageListService.didChangeNotification,
            object: nil
        )

        XCTAssertEqual(presenter.photos.count, 1)
        XCTAssertTrue(view.updateTableViewAnimatedCalled)
    }

    func testWillDisplayLastCellFetchesNextPage() {
        let service = ImageListServiceSpy(photos: [makePhoto()])
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view
        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: ImageListService.didChangeNotification,
            object: nil
        )

        presenter.willDisplayCell(at: 0)

        XCTAssertEqual(service.fetchCallCount, 2)
    }

    func testDidTapLikeCallsChangeLike() {
        let service = ImageListServiceSpy(photos: [makePhoto(isLiked: false)])
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter(service: service)
        presenter.view = view
        presenter.viewDidLoad()
        NotificationCenter.default.post(
            name: ImageListService.didChangeNotification,
            object: nil
        )

        presenter.didTapLike(at: 0)

        XCTAssertTrue(service.changeLikeCalled)
        XCTAssertTrue(view.setIsLikedCalled)
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [PhotoUIModel] = []
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photosCount() -> Int { photos.count }
    func photo(at index: Int) -> PhotoUIModel { photos[index] }
    func largeImageURL(at index: Int) -> URL? { nil }
    func willDisplayCell(at index: Int) {}
    func didTapLike(at index: Int) {}
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled = false
    var showErrorCalled = false
    var showLoadingCalled = false
    var hideLoadingCalled = false
    var setIsLikedCalled = false

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }

    func showError() {
        showErrorCalled = true
    }

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }

    func setIsLiked(at index: Int, isLiked: Bool) {
        setIsLikedCalled = true
    }
}

final class ImageListServiceSpy: ImageListServiceProtocol {
    private(set) var photos: [PhotoUIModel]
    var fetchCallCount = 0
    var changeLikeCalled = false

    init(photos: [PhotoUIModel] = []) {
        self.photos = photos
    }

    func fetchPhotosNextPage() {
        fetchCallCount += 1
    }

    func changeLike(
        photoId: String,
        isLiked: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        changeLikeCalled = true
        completion(.success(()))
    }
}
