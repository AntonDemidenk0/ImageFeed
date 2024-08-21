//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 17.8.24..
//

import Foundation
import UIKit

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
    
    private let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = .current
        return formatter
    }()
    
    // MARK: - ImagesListPresenterProtocol
    
    func numberOfRows() -> Int {
        return imagesListService.photos.count
    }
    
    func configureCell(_ cell: ImagesListCellProtocol, at indexPath: IndexPath) {
        let photo = imagesListService.photos[indexPath.row]
        
        cell.customImageView.kf.indicatorType = .activity
        if let url = URL(string: photo.thumbImageURL) {
            cell.customImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Placeholder"),
                options: nil,
                progressBlock: nil,
                completionHandler: { [weak self] result in
                    switch result {
                    case .success:
                        self?.view?.tableView.performBatchUpdates({
                            self?.view?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }, completion: nil)
                    case .failure(let error):
                        print("Error loading image: \(error)")
                    }
                }
            )
        }
        
        if let createdAtString = photo.createdAt,
           let createdAt = isoDateFormatter.date(from: createdAtString) {
            dateFormatter.locale = .current
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
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
