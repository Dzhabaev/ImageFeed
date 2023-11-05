//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Чингиз Джабаев on 11.09.2023.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton.systemButton(with: UIImage(named: "logout_button")!,
                                                     target: self,
                                                     action: #selector(didTapLogoutButton))
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileDetails(profile: profileService.profile)
        observeAvatarChanges()
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
        avatarImageView.image = UIImage(named: "avatar_image")
    }
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
    }
    private func setupLoginNameLabel() {
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
    }
    private func setupDescriptionLabel() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
    }
    private func setupLogoutButton() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
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
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func didTapLogoutButton() {
    }
}

extension ProfileViewController {
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profileService.profile else {return}
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
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
            placeholder: UIImage(named: "placeholder"),
            options: [.processor(processor)]
        )
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
    }
}
