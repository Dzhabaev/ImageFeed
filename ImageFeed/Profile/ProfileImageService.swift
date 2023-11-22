//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Chingiz on 03.11.2023.
//

import Foundation
import UIKit

final class ProfileImageService {
    
    // MARK: - Singleton Instance
    static let shared = ProfileImageService()
    
    // MARK: - Notification
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Private Properties
    private let storageToken = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var avatarURL: String?
    
    // MARK: - Clean Up
    func clean() {
        avatarURL = nil
        task?.cancel()
        task = nil
    }
    
    // MARK: - Fetch Profile Image URL
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request = makeRequest(token: storageToken.token!, username: username)
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let decodedObject):
                let avatarURL = ProfileImage(decodedData: decodedObject)
                self.avatarURL = avatarURL.profileImage["large"]
                completion(.success((self.avatarURL!)))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.DidChangeNotification,
                        object: self,
                        userInfo: ["URL": self.avatarURL!]
                    )
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Helper Methods
    private func makeRequest(token: String, username: String) -> URLRequest {
        guard let url = URL(string: "\(AuthConfiguration.standard.apiBaseURL)" + "/users/" + username) else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
