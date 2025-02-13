//  ProfileViewTests.swift
//  Image FeedTests
//
//  Created by Anton Demidenko on 17.8.24..

@testable import ImageFeed
import XCTest

// MARK: - Mocks

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: ProfileResult?
    var fetchProfileCalled = false
    var resetProfileCalled = false
    
    func fetchProfile(completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        fetchProfileCalled = true
        if let profile = profile {
            completion(.success(profile))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
        }
    }
    
    func resetProfile() {
        resetProfileCalled = true
    }
}

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?
    var fetchProfileImageURLCalled = false
    var resetImageURLCalled = false
    
    func fetchProfileImageURL(_ completion: @escaping (Result<String, Error>) -> Void) {
        fetchProfileImageURLCalled = true
        if let url = avatarURL {
            completion(.success(url))
        } else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
        }
    }
    
    func resetImageURL() {
        resetImageURLCalled = true
    }
}

final class ProfileViewControllerMock: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var presenter: ProfilePresenterProtocol?
    
    func updateProfileDetails() {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
}

final class ProfileTests: XCTestCase {
    var profileServiceMock: ProfileServiceMock!
    var profileImageServiceMock: ProfileImageServiceMock!
    var viewControllerMock: ProfileViewControllerMock!
    var presenter: ProfileViewPresenter!
    
    override func setUp() {
        super.setUp()
        profileServiceMock = ProfileServiceMock()
        profileImageServiceMock = ProfileImageServiceMock()
        viewControllerMock = ProfileViewControllerMock()
        presenter = ProfileViewPresenter(profileService: profileServiceMock, profileImageService: profileImageServiceMock)
        viewControllerMock.presenter = presenter
        presenter.view = viewControllerMock
    }
    
    func testFetchProfileUpdatesView() {
        let profile = ProfileResult(username: "testuser", first_name: "First", last_name: "Last", bio: "Bio")
        profileServiceMock.profile = profile
        
        presenter.fetchProfile()
        
        XCTAssertTrue(profileServiceMock.fetchProfileCalled, "fetchProfile() should be called on profileServiceMock")
        XCTAssertTrue(viewControllerMock.updateProfileDetailsCalled, "updateProfileDetails() should be called on viewControllerMock")
    }
    
    func testFetchProfileImageUpdatesView() {
        let imageURL = "http://test.url"
        profileImageServiceMock.avatarURL = imageURL
        
        presenter.fetchProfileImage()
        
        XCTAssertTrue(profileImageServiceMock.fetchProfileImageURLCalled, "fetchProfileImageURL() should be called on profileImageServiceMock")
        XCTAssertTrue(viewControllerMock.updateAvatarCalled, "updateAvatar() should be called on viewControllerMock")
    }
    
    func testFetchProfileHandlesFailure() {
        profileServiceMock.profile = nil
        
        presenter.fetchProfile()
        
        XCTAssertTrue(profileServiceMock.fetchProfileCalled, "fetchProfile() should be called on profileServiceMock")
        XCTAssertFalse(viewControllerMock.updateProfileDetailsCalled, "updateProfileDetails() should not be called on viewControllerMock")
    }
    
    func testFetchProfileImageHandlesFailure() {
        profileImageServiceMock.avatarURL = nil
        
        presenter.fetchProfileImage()
        
        XCTAssertTrue(profileImageServiceMock.fetchProfileImageURLCalled, "fetchProfileImageURL() should be called on profileImageServiceMock")
        XCTAssertFalse(viewControllerMock.updateAvatarCalled, "updateAvatar() should not be called on viewControllerMock")
    }
}
