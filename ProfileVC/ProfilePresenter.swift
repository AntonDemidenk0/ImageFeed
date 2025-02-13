//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 17.8.24..
//

import Foundation

// MARK: - ProfilePresenterProtocol

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func fetchProfile()
    func fetchProfileImage()
}

// MARK: - ProfileViewPresenter

final class ProfileViewPresenter: ProfilePresenterProtocol {
    // MARK: - Properties
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    // MARK: - Initializers
    
    init(profileService: ProfileServiceProtocol, profileImageService: ProfileImageServiceProtocol) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        fetchProfile()
        fetchProfileImage()
    }
    
    func fetchProfile() {
        profileService.fetchProfile { [weak self] result in
            switch result {
            case .success:
                self?.view?.updateProfileDetails()
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }
    
    func fetchProfileImage() {
        profileImageService.fetchProfileImageURL { [weak self] result in
            switch result {
            case .success:
                self?.view?.updateAvatar()
            case .failure(let error):
                print("Error fetching profile image: \(error)")
            }
        }
    }
}
