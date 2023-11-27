//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Чингиз Джабаев on 26.08.2023.
//

import Kingfisher
import UIKit

// MARK: - ImagesListViewControllerProtocol
protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? {get set}
    func updateTableViewAnimated()
    var photos: [Photo] {get set}
}

// MARK: - ImagesListViewController
final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    
    // MARK: - Public Properties
    var presenter: ImagesListPresenterProtocol? = {
        return ImageListPresenter()
    } ()
    var photos: [Photo] = []
    
    // MARK: - IB Outlets
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        presenter?.view = self
        presenter?.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let imageURL = URL(string: photos[indexPath.row].fullImageURL)
            viewController.fullImageURL = imageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Action Methods
    @objc func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount > newCount {
            let indexPathsToDelete = (newCount..<oldCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
        } else if oldCount < newCount {
            let indexPathsToInsert = (oldCount..<newCount).map { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPathsToInsert, with: .automatic)
        }
    }
    
    // MARK: - Methods
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == imagesListService.photos.count {
            presenter?.fetchPhotosNextPage()
        } else {
            return
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

//MARK: - Config Cell Extension
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageURL = photos[indexPath.row].thumbImageURL
        let url = URL(string: imageURL)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "loadImageList")) { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                cell.cellImage.kf.indicatorType = .none
            }
        cell.configureGradient()
        if let date = imagesListService.photos[indexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        let isLiked = imagesListService.photos[indexPath.row].isLiked == false
        let like = isLiked ? UIImage(named: "likeButtonOff") : UIImage(named: "likeButtonOn")
        cell.likeButton.setImage(like, for: .normal)
        cell.selectionStyle = .none
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = photos[indexPath.row]
        let imageSize = CGSize(width: cell.width, height: cell.height)
        let aspectRatio = imageSize.width / imageSize.height
        return tableView.frame.width / aspectRatio
    }
}

//MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        presenter?.setLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    guard let newPhotos = self.presenter?.imagesListService.photos else {return}
                    self.photos = newPhotos
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    self.showLikeErrorAlert(with: error)
                }
            }
        }
    }
    private func showLikeErrorAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
