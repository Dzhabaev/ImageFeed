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
    
    // MARK: - UI Elements
    private let authScreenLogo: UIImageView = {
        let authScreenLogo = UIImageView()
        authScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        authScreenLogo.image = UIImage(named: "authScreenLogo")
        return authScreenLogo
    }()
    
    private let signInButton: UIButton = {
        let signInButton = UIButton()
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.setTitle("Войти", for: .normal)
        signInButton.setTitleColor(.ypBlack, for: .normal)
        signInButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        signInButton.backgroundColor = .ypWhite
        signInButton.addTarget(
            self,
            action: #selector(didTapSignIn),
            for: .touchUpInside
        )
        signInButton.layer.cornerRadius = 16
        return signInButton
    }()
    
    //MARK: - Properties
    weak var delegate: AuthViewControllerDelegate?
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service()
    
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addSubview()
        applyConstraints()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            let webViewPresenter = WebViewPresenter()
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Action Methods
    @objc private func didTapSignIn() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - UI Setup Methods
    private func addSubview() {
        view.addSubview(authScreenLogo)
        view.addSubview(signInButton)
    }
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            authScreenLogo.heightAnchor.constraint(equalToConstant: 60),
            authScreenLogo.widthAnchor.constraint(equalToConstant: 60),
            authScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signInButton.heightAnchor.constraint(equalToConstant: 48),
            signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
