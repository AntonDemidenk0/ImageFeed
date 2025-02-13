//  ImagesListTests.swift
//  Image FeedTests
//
//  Created by Anton Demidenko on 18.8.24.
//

import XCTest
import UIKit
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    var viewController: ImagesListViewController!
    var presenter: ImagesListPresenterMock!
    var service: ImagesListServiceMock!
    var tableView: MockTableView!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        service = ImagesListServiceMock()
        presenter = ImagesListPresenterMock()
        presenter.service = service
        viewController.configure(presenter: presenter)
        
        tableView = MockTableView()
        viewController.tableView = tableView
        viewController.tableView.dataSource = viewController
        viewController.tableView.delegate = viewController
        
        viewController.loadViewIfNeeded()
    }
    
    // MARK: - ImagesListViewController Tests
    
    func testUpdateTableViewAnimated_NoChangeInPhotoCount() {
        let photo = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
        
        service.photos = [photo]
        viewController.updateTableViewAnimated()
        
        tableView.reset()
        service.photos = [photo]
        viewController.updateTableViewAnimated()
        
        XCTAssertFalse(tableView.insertRowsCalled, "Expected no rows to be inserted")
    }
    
    func testUpdateTableViewAnimated_NewPhotosAdded() {

        let initialPhoto = Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
        
        let newPhoto = Photo(
            id: "2",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb2.jpg",
            largeImageURL: "https://example.com/large2.jpg",
            isLiked: false
        )
        
        service.photos = [initialPhoto]
        viewController.updateTableViewAnimated()
        
        tableView.reset()
        service.photos.append(newPhoto)
        viewController.updateTableViewAnimated()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.tableView.insertRowsCalled, "Expected rows to be inserted")
            XCTAssertEqual(self.tableView.insertRowsIndexPaths.count, 1, "Expected 1 row to be inserted")
            
            let insertedIndexPath = self.tableView.insertRowsIndexPaths.first
            XCTAssertEqual(insertedIndexPath?.row, 1, "Expected row index to be 1")
        }
    }
    
    func testConfigureCell() {
        let cell = TestImagesListCell()
        let indexPath = IndexPath(row: 0, section: 0)
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)]
        
        presenter.configureCell(cell, at: indexPath)
        
        XCTAssertNotNil(cell.customImageView.image)
    }
    
    func testPrepareForSegue() {
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "thumb", largeImageURL: "large", isLiked: false)
        viewController.photos = [photo]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let singleImageViewController = storyboard.instantiateViewController(withIdentifier: "SingleImageViewController") as! SingleImageViewController
        
        let segue = UIStoryboardSegue(identifier: viewController.showSingleImageSegueIdentifier, source: viewController, destination: singleImageViewController)
        
        let indexPath = IndexPath(row: 0, section: 0)
        viewController.prepare(for: segue, sender: indexPath)
        
        XCTAssertEqual(singleImageViewController.imageURL, URL(string: photo.largeImageURL))
    }
    
    func testTableViewHeightForRowAt() {
        let indexPath = IndexPath(row: 0, section: 0)
        let photo = Photo(id: "1", size: CGSize(width: 100, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
        viewController.photos = [photo]
        
        let height = viewController.tableView(viewController.tableView, heightForRowAt: indexPath)
        
        let expectedHeight = viewController.tableView.frame.width * photo.size.height / photo.size.width
        XCTAssertEqual(height, expectedHeight, accuracy: 0.01)
    }
    
    // MARK: - ImagesListPresenter Tests
    
    func testNumberOfRows() {
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)]
        
        let rows = presenter.numberOfRows()
        
        XCTAssertEqual(rows, 1)
    }
    
    func testDidSelectRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        
        presenter.didSelectRow(at: indexPath)
        
        XCTAssertTrue(presenter.performSegueCalled)
    }
    
    func testFetchNextPage() {
        presenter.fetchNextPage()
        
        XCTAssertTrue(service.fetchNextPageCalled)
    }
    
    func testHandlePhotosUpdated() {
        service.photos = [Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)]
        
        presenter.handlePhotosUpdated()
        
        XCTAssertTrue(presenter.updateTableViewAnimatedCalled)
    }
}

final class ImagesListPresenterMock: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var performSegueCalled = false
    var updateTableViewAnimatedCalled = false
    var service: ImagesListServiceProtocol?
    
    func numberOfRows() -> Int {
        return 1
    }
    
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath) {
        cell.customImageView.image = UIImage()
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        performSegueCalled = true
    }
    
    func fetchNextPage() {
        service?.fetchPhotosNextPage()
    }
    
    func handlePhotosUpdated() {
        updateTableViewAnimatedCalled = true
    }
}

final class ImagesListServiceMock: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchNextPageCalled = false
    
    func fetchPhotosNextPage() {
        fetchNextPageCalled = true
    }
    
    var changeLikeCalled = false
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

final class TestImagesListCell: ImagesListCellProtocol {
    var dateLabel: UILabel!
    var customImageView: UIImageView! = UIImageView()
    
    func setIsLiked(_ isLiked: Bool) {
    }
}

final class MockTableView: UITableView {
    var insertRowsCalled = false
    var insertRowsIndexPaths: [IndexPath] = []
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertRowsCalled = true
        insertRowsIndexPaths = indexPaths
    }
    
    func reset() {
        insertRowsCalled = false
        insertRowsIndexPaths.removeAll()
    }
}
