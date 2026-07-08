import XCTest

@testable import ImageFeed

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImageListService.shared
        let exp = expectation(description: "Wait for Notification")

        NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            exp.fulfill()
        }

        service.fetchPhotosNextPage() {_ in }
        wait(for: [exp], timeout: 10)

        XCTAssertEqual(service.photos.count, 10)

    }

}
