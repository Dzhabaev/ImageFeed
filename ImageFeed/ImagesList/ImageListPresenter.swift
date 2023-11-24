//
//  ImageListPresenter.swift
//  ImageFeed
//
//  Created by Chingiz on 23.11.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? {get set}
    var imagesListService: ImagesListService {get}
    func viewDidLoad()
    func fetchPhotosNextPage()
    func setLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    
}

final class ImageListPresenter: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    let imagesListService = ImagesListService.shared
    
    func viewDidLoad() {
        setupObservers()
        imagesListService.fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage(){
        imagesListService.fetchPhotosNextPage()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.view?.updateTableViewAnimated()
        }
    }
    
    func setLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        imagesListService.changeLike(photoId: photoId, isLike: isLike, {[weak self] result in
            guard self != nil else { return }
            switch result{
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
                print(error.localizedDescription)
            }
        })
    }
}
