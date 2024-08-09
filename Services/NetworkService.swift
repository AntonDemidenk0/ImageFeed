//
//  NetworkService.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 8.8.24..
//

import Foundation

// MARK: - NetworkService Class
final class NetworkService {
    
    // MARK: - Singleton
    static let shared = NetworkService()
    private init() {}
    
    // MARK: - Properties
    private let defaultBaseURL = Constants.defaultBaseURL
    
    // MARK: - Public Methods
    
    // MARK: OAuth Token Request
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Invalid base URL")
            return nil
        }
        
        let urlString = "/oauth/token"
        + "?client_id=\(Constants.accessKey)"
        + "&client_secret=\(Constants.secretKey)"
        + "&redirect_uri=\(Constants.redirectURI)"
        + "&code=\(code)"
        + "&grant_type=authorization_code"
        
        guard let url = URL(string: urlString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: Profile Info Request
    func makeProfileInfoRequest() -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        
        let profileURLString = "/me"
        guard let url = URL(string: profileURLString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        if let token = Constants.tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        request.httpMethod = "GET"
        return request
    }
    
    // MARK: Profile Picture Request
    func makeProfilePicRequest(username: String) -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        let profilePicString = "/users/\(username)"
        guard let url = URL(string: profilePicString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        var request = URLRequest(url: url)
        if let token = Constants.tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        
        request.httpMethod = "GET"
        return request
    }
    
    // MARK: Photos Request
    func makePhotosRequest(page: Int) -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        let urlString = "/photos?page=\(page)"
        guard let url = URL(string: urlString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        if let token = Constants.tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        
        request.httpMethod = "GET"
        return request
    }
    
    // MARK: Like Request
    func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let baseURL = defaultBaseURL else {
            print("Invalid base URL")
            return nil
        }
        let urlString = "/photos/\(photoId)/like"
        guard let url = URL(string: urlString, relativeTo: baseURL) else {
            print("Invalid URL string")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        if let token = Constants.tokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token not found")
            return nil
        }
        return request
    }
}
