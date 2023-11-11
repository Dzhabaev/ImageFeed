//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Chingiz on 27.09.2023.
//

import UIKit

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    private let signInButton = UIButton()
    private let authScreenLogo = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .ypBlack
    }
    
    @objc private func didTapSignIn() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service()
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setupUI() {
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.setTitle("Войти", for: .normal)
        signInButton.setTitleColor(.ypBlack, for: .normal)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        signInButton.backgroundColor = .ypWhite
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        signInButton.layer.cornerRadius = 16
        
        view.addSubview(authScreenLogo)
        authScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        authScreenLogo.image = UIImage(named: "authScreenLogo")
        
        NSLayoutConstraint.activate([
            signInButton.heightAnchor.constraint(equalToConstant: 48),
            signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            authScreenLogo.heightAnchor.constraint(equalToConstant: 60),
            authScreenLogo.widthAnchor.constraint(equalToConstant: 60),
            authScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
