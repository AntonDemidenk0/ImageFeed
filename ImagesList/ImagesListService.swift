//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 31.7.24..
//

import Foundation
import UIKit

// MARK: - Photo Struct
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - Array Extension
extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - ImagesListService Class
final class ImagesListService: ImagesListServiceProtocol {
    
    // MARK: - Static Properties
    static let shared = ImagesListService()
    private init() {}
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Properties
    private (set) var photos: [Photo] = []
    private var isFetching: Bool = false
    private var task: URLSessionTask?
    private var nextPage = 0
    
    // MARK: - Fetch Photos Next Page
    func fetchPhotosNextPage() {
        guard !isFetching, task == nil else { return }
        isFetching = true
        
        guard let request = NetworkService.shared.makePhotosRequest(page: nextPage) else {
            isFetching = false
            return
        }
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            
            defer { self?.isFetching = false
                self?.task = nil }
                
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
                    
                    self?.photos.append(contentsOf: photos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    
                case .failure(let error):
                    print("Failed to fetch photos: \(error)")
                }
        }
        nextPage += 1
        task?.resume()
    }
    
    // MARK: - Change Like Status
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let request = NetworkService.shared.makeLikeRequest(photoId: photoId, isLike: isLike) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                let photo = self?.photos[index]
                let newPhoto = Photo(
                    id: photo?.id ?? "",
                    size: photo?.size ?? CGSize.zero,
                    createdAt: photo?.createdAt,
                    welcomeDescription: photo?.welcomeDescription,
                    thumbImageURL: photo?.thumbImageURL ?? "",
                    largeImageURL: photo?.largeImageURL ?? "",
                    isLiked: !(photo?.isLiked ?? false)
                )
                
                self?.photos = self?.photos.withReplaced(itemAt: index, newValue: newPhoto) ?? []
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Photo not found"])))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Reset Images
    func resetImages() {
        self.photos = []
    }
}
