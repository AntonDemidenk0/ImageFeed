//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 31.7.24..
//

import Foundation
import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - ImagesListService

final class ImagesListService {
    
    static let shared = ImagesListService()
    private init() {}
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var isFetching: Bool = false
    private var task: URLSessionTask?
    private var nextPage = 0
    
    // MARK: - Fetch Photos Next Page
    
    func fetchPhotosNextPage() {
        guard !isFetching, task == nil else { return }
        isFetching = true
        
        nextPage += 1
        
        guard let request = Constants.makePhotosRequest(page: nextPage) else {
            isFetching = false
            return
        }
        task = URLSession.shared.objectTask(for: request) { (result: Result<[ImageResult], Error>) in
            DispatchQueue.main.async {
                self.isFetching = false
                self.task = nil
            }
            
            switch result {
            case .success(let newPhotos):
                let photos = newPhotos.map { imageResult in
                    return Photo(
                        id: imageResult.id,
                        size: CGSize(width: imageResult.width, height: imageResult.height),
                        createdAt: imageResult.created_at,
                        welcomeDescription: imageResult.description,
                        thumbImageURL: imageResult.urls.thumb,
                        largeImageURL: imageResult.urls.full,
                        isLiked: imageResult.liked_by_user
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: photos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                }
            case .failure(let error):
                print("Failed to fetch photos: \(error)")
            }
        }
        task?.resume()
    }
    
}
