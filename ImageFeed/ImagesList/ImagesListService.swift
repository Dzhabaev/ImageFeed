//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Chingiz on 08.11.2023.
//

import Foundation

final class ImagesListService {
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    
    private init(){}
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let storageToken = OAuth2TokenStorage.shared
    private let perPage = "10"
    private let dateFormatter = ISO8601DateFormatter()
    
    func updatePhotos(_ photos: [Photo]) {
        self.photos = photos
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
                            name: ImagesListService.DidChangeNotification,
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
    
    private func imagesListRequest(_ token: String, page: String, perPage: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURL: Constants.apiBaseURL
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
            isLiked: photoResult.isLiked ?? false)
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
    
    private func makeLikeRequest(_ token: String, photoId: String, httpMethod: String) -> URLRequest? {
        var request = URLRequest.makeHTTPRequest(
            path: "photos/\(photoId)/like",
            httpMethod: httpMethod,
            baseURL: Constants.apiBaseURL
        )
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func postLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        return makeLikeRequest(token, photoId: photoId, httpMethod: "POST")
    }
    
    func deleteLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        return makeLikeRequest(token, photoId: photoId, httpMethod: "DELETE")
    }
}

extension Array {
    func withReplaced(itemAt: Int, newValue: Photo) -> [Photo] {
        var photos = ImagesListService.shared.photos
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
}
