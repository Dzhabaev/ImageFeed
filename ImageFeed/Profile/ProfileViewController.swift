//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Чингиз Джабаев on 11.09.2023.
//

import UIKit
import Kingfisher
import WebKit
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton.systemButton(
        with: UIImage(named: "exitButton")!,
        target: self,
        action: #selector(didTapLogoutButton)
    )
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileDetails(profile: profileService.profile)
        observeAvatarChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAvatar()
    }
    
    private func setupUI() {
        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        setupConstraints()
    }
    private func setupAvatarImageView() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
    }
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
    }
    private func setupLoginNameLabel() {
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
    }
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.isUserInteractionEnabled = true
        
        let attributedString = NSMutableAttributedString(string: "To fill out a Bio, go to the website https://unsplash.com/ and edit the profile in the Bio section and then don’t forget to click the 'Update account' button at the bottom.")
        attributedString.addAttribute(.link, value: "https://unsplash.com/", range: NSMakeRange(31, 18))
        descriptionLabel.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLink(_:)))
        descriptionLabel.addGestureRecognizer(tapGesture)
    }
    private func setupLogoutButton() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.tintColor = .ypRed
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapLogoutButton() {
        logoutAlert()
    }
    
    private func logoutAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default,
            handler: { [ weak self ] action in
                guard let self = self else { return }
                self.clean()
                self.goToSplashViewController()
            })
        )
        
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .cancel,
            handler: nil)
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    private func clean() {
        KeychainWrapper.standard.removeAllKeys()
        WebViewViewController.clean()
        ImagesListService.shared.clean()
        ProfileImageService.shared.clean()
        ProfileService.shared.clean()
    }
    
    private func goToSplashViewController() {
        let viewController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = viewController
    }
    
    @objc private func didTapLink(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://unsplash.com/account/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension ProfileViewController {
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profileService.profile else {return}
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        if let bio = profile.bio, !bio.isEmpty {
            descriptionLabel.text = bio
        } else {
            descriptionLabel.text = "To fill out a Bio, go to the website 'https://unsplash.com/' and edit the profile in the 'Bio' section and then don’t forget to click the 'Update account' button at the bottom."
        }
    }
    
    private func observeAvatarChanges(){
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.DidChangeNotification,
                object: nil,
                queue: .main
            ){
                [weak self] _ in
                guard let self = self else {return}
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }
        avatarImageView.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "loadAvatar"),
            options: [.processor(processor)]
        )
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
    }
}
