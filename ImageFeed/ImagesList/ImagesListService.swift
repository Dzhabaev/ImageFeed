//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Chingiz on 08.11.2023.
//

import Foundation

final class ImagesListService {
    
    // MARK: - Singleton Instance
    static let shared = ImagesListService()
    
    // MARK: - Notifications
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    
    // MARK: - Initializers
    private init(){}
    
    // MARK: - Private Properties
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let storageToken = OAuth2TokenStorage.shared
    private let perPage = "10"
    private let dateFormatter = ISO8601DateFormatter()
    
    // MARK: - Public Methods
    func updatePhotos(_ photos: [Photo]) {
        self.photos = photos
    }
    
    func clean(){
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
    }
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else {
            return
        }
        let page = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        let request = imagesListRequest(storageToken.token!, page: String(page), perPage: perPage)
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let photoResults):
                    for photoResult in photoResults {
                        self.photos.append(self.convert(photoResult))
                    }
                    self.lastLoadedPage = page
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["Images" : self.photos]
                        )
                case .failure(let error):
                    assertionFailure("Ошибка получения изображений \(error)")
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void){
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = storageToken.token else { return }
        var request: URLRequest?
        if !isLike {
            request = postLikeRequest(token, photoId: photoId)
        } else {
            request = deleteLikeRequest(token, photoId: photoId)
        }
        guard let request = request else {return}
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let photoResult):
                let isLiked = photoResult.photo?.isLiked ?? false
                if let index = self.photos.firstIndex(where: {$0.id == photoResult.photo?.id}) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(id: photo.id,
                                         width: photo.width,
                                         height: photo.height,
                                         createdAt: photo.createdAt,
                                         welcomeDescription: photo.welcomeDescription,
                                         thumbImageURL: photo.thumbImageURL,
                                         largeImageURL: photo.largeImageURL,
                                         fullImageURL: photo.fullImageURL,
                                         isLiked: isLiked)
                    self.photos = self.photos.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private func imagesListRequest(_ token: String, page: String, perPage: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURL: AuthConfiguration.standard.authApiBaseURL
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func convert(_ photoResult: PhotoResult) -> Photo {
        return Photo.init(
            id: photoResult.id,
            width: CGFloat(photoResult.width),
            height: CGFloat(photoResult.height),
            createdAt: self.dateFormatter.date(from:photoResult.createdAt),
            welcomeDescription: photoResult.description,
            thumbImageURL: (photoResult.urls?.thumb)!,
            largeImageURL: (photoResult.urls?.full)!,
            fullImageURL: (photoResult.urls?.full)!,
            isLiked: photoResult.isLiked ?? false)
    }
    
    private func makeLikeRequest(_ token: String, photoId: String, httpMethod: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(
            path: "photos/\(photoId)/like",
            httpMethod: httpMethod,
            baseURL: AuthConfiguration.standard.authApiBaseURL
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func postLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        return makeLikeRequest(token, photoId: photoId, httpMethod: "POST")
    }
    
    private func deleteLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        return makeLikeRequest(token, photoId: photoId, httpMethod: "DELETE")
    }
}
