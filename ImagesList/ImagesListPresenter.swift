//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 17.8.24..
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    func numberOfRows() -> Int
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath)
    func didSelectRow(at indexPath: IndexPath)
    func fetchNextPage()
    func handlePhotosUpdated()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    
    // MARK: - Properties
    
    private weak var view: ImagesListViewController?
    private let imagesListService: ImagesListServiceProtocol
    
    init(view: ImagesListViewController, imagesListService: ImagesListServiceProtocol) {
        self.view = view
        self.imagesListService = imagesListService
    }
    
    // MARK: - ImagesListPresenterProtocol
    
    func numberOfRows() -> Int {
        return imagesListService.photos.count
    }
    
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        
        cell.configure(with: photo)
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        view?.performSegue(withIdentifier: view?.showSingleImageSegueIdentifier ?? "", sender: indexPath)
    }
    
    func fetchNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func handlePhotosUpdated() {
        view?.updateTableViewAnimated()
    }
}
