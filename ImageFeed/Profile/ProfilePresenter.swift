//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Chingiz on 22.11.2023.
//

import Foundation
import Kingfisher
import SwiftKeychainWrapper
import UIKit

// MARK: - ProfilePresenterProtocol
public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func clean()
}

// MARK: - ProfilePresenter
final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Properties
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Initialization
    init(view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    // MARK: - Public Methods
    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else {
            return
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        let placeholderImage = UIImage(named: "loadAvatar")
        
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: [.processor(processor)],
            completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let value):
                    self.view?.setAvatarImage(value.image)
                case .failure:
                    self.view?.setAvatarImage(placeholderImage)
                }
            }
        )
        
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
    }
    
    func viewDidLoad() {
        updateProfileDetails()
        observeAvatarChanges()
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {return}
        view?.setName(profile.name)
        view?.setLoginName(profile.loginName)
        if let bio = profile.bio, !bio.isEmpty {
            view?.setDescription(bio)
        } else {
            view?.setDescription("To fill out a Bio, go to the website 'https://unsplash.com/' and edit the profile in the 'Bio' section and then don’t forget to click the 'Update account' button at the bottom.")
        }
    }
    
    private func observeAvatarChanges() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else {return}
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    
    // MARK: - Logout
    func clean() {
        KeychainWrapper.standard.removeAllKeys()
        WebViewViewController.clean()
        ImagesListService.shared.clean()
        ProfileImageService.shared.clean()
        ProfileService.shared.clean()
    }
}
