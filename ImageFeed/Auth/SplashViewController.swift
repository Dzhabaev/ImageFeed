//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Chingiz on 02.10.2023.
//

import ProgressHUD
import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - UI Elements
    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "launchScreen")
        return logoImageView
    }()
    
    // MARK: - Private Properties
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service()
    
    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard UIBlockingProgressHUD.isShowing == false else { return }
        
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
            switchToTabBarController()
        } else {
            let authViewController = AuthViewController()
            authViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: authViewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .ypBlack
        view.addSubview(logoImageView)
        applyConstraints()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Public Methods
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    // MARK: - Private Methods
    private func applyConstraints() {
        NSLayoutConstraint.activate([
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.oauth2TokenStorage.token = token
                self.fetchProfile(token: token)
                UIBlockingProgressHUD.dismiss()
            case .failure (let error):
                self.showAlert(with: error)
                break
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let username = self.profileService.profile?.username else { return }
                self.profileImageService.fetchProfileImageURL(username: username)  { _ in }
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
            case .failure (let error):
                self.showAlert(with: error)
                break
            }
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    private func showAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
