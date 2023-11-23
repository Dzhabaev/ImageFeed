//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Чингиз Джабаев on 11.09.2023.
//

import UIKit

// MARK: - ProfileViewControllerProtocol
public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func setName(_ name: String)
    func setLoginName(_ loginName: String)
    func setDescription(_ description: String)
    func setAvatarImage(_ image: UIImage?)
}

// MARK: - ProfileViewController
final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    //MARK: - Properties
    var presenter: ProfilePresenterProtocol?
    
    // MARK: - UI Elements
    private let avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        return avatarImageView
    }()
    
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.textColor = .white
        return nameLabel
    }()
    
    private let loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        return loginNameLabel
    }()
    
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.isUserInteractionEnabled = true
        let attributedString = NSMutableAttributedString(string: "To fill out a Bio, go to the website https://unsplash.com/ and edit the profile in the Bio section and then don’t forget to click the 'Update account' button at the bottom.")
        attributedString.addAttribute(.link, value: "https://unsplash.com/", range: NSMakeRange(31, 18))
        descriptionLabel.attributedText = attributedString
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapLink(_:))
        )
        descriptionLabel.addGestureRecognizer(tapGesture)
        return descriptionLabel
    }()
    
    private let logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "exitButton")!,
            target: self,
            action: #selector(didTapLogoutButton)
        )
        logoutButton.accessibilityIdentifier = "logout button"
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.tintColor = .ypRed
        return logoutButton
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubview()
        applyConstraints()
        presenter?.viewDidLoad()
        view.backgroundColor = .ypBlack
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.updateAvatar()
    }
    
    // MARK: - Action Methods
    @objc private func didTapLogoutButton() {
        logoutAction()
    }
    
    @objc private func didTapLink(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: "https://unsplash.com/account/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - UI Setup Methods
    private func addSubview() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func applyConstraints() {
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
    
    // MARK: - Methods
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setLoginName(_ loginName: String) {
        loginNameLabel.text = loginName
    }
    
    func setDescription(_ description: String) {
        descriptionLabel.text = description
    }
    
    func setAvatarImage(_ image: UIImage?) {
        avatarImageView.image = image
    }
    
    // MARK: - Logout
    private func logoutAction() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Bye bye!"
        
        alert.addAction(UIAlertAction(
            title: "Да",
            style: .default,
            handler: { [ weak self ] action in
                guard let self = self else { return }
                self.presenter?.clean()
                self.goToSplashViewController()
            })
        )
        alert.actions.first?.accessibilityIdentifier = "Yes"
        
        alert.addAction(UIAlertAction(
            title: "Нет",
            style: .cancel,
            handler: nil)
        )
        
        present(alert, animated: true, completion: nil)
    }
    
    private func goToSplashViewController() {
        let viewController = SplashViewController()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = viewController
    }
}
