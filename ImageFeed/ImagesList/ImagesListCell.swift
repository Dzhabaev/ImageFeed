//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Чингиз Джабаев on 26.08.2023.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    private var gradientInited = false
    weak var delegate: ImagesListCellDelegate?
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
    }

    func configureGradient() {
        if !gradientInited {
            let gradient = CAGradientLayer()
            gradient.frame = gradientView.bounds
            gradient.colors = [UIColor.clear.cgColor, UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor]
            gradientView.layer.insertSublayer(gradient, at: 0)
            gradientInited = true
        }
    }
    
    func setIsLiked(isLiked: Bool){
        let like = isLiked ? UIImage(named: "likeButtonOn") : UIImage(named: "likeButtonOff")
        likeButton.imageView?.image = like
        likeButton.setImage(like, for: .normal)
    }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}
