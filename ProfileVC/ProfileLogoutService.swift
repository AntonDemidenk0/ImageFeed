//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Anton Demidenko on 6.8.24..
//

import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        clearAppData()
        navigateToSplashScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func clearAppData() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        KeychainWrapper.standard.removeAllKeys()
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetImageURL()
        ImagesListService.shared.resetImages()
    }
    
    private func navigateToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { return }
        let splashViewController = SplashViewController()
        let navigationController = UINavigationController(rootViewController: splashViewController)
        navigationController.modalPresentationStyle = .fullScreen
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

