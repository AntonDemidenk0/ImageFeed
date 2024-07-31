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
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - ImagesListService

final class ImagesListService {
    
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var isFetching: Bool = false
    private var lastLoadedPage: Int?
    
    // MARK: - Fetch Photos Next Page
    
    func fetchPhotosNextPage() {
         let nextPage = (lastLoadedPage ?? 0) + 1
         
         guard !isFetching else { return }
         isFetching = true
         
         let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&client_id=\(Constants.accessKey)"
         guard let url = URL(string: urlString) else {
             isFetching = false
             return
         }
         
         let request = URLRequest(url: url)
         
         let task = URLSession.shared.objectTask(for: request) { (result: Result<[ImageResult], Error>) in
             self.isFetching = false
             
             switch result {
             case .success(let imageResults):
                 let newPhotos = imageResults.map { imageResult in
                     return Photo(
                         id: imageResult.id,
                         size: CGSize(width: CGFloat(imageResult.width), height: CGFloat(imageResult.height)),
                         createdAt: imageResult.created_at,
                         welcomeDescription: imageResult.description,
                         thumbImageURL: imageResult.imageUrls.thumb,
                         largeImageURL: imageResult.imageUrls.full,
                         isLiked: imageResult.liked_by_user
                     )
                 }
                 
                 DispatchQueue.main.async {
                     self.photos.append(contentsOf: newPhotos)
                     NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                 }
                 
             case .failure(let error):
                 print("Failed to fetch photos: \(error)")
             }
         }
         
         task.resume()
         lastLoadedPage = nextPage
     }
 }
