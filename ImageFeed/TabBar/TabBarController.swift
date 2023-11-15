//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Chingiz on 06.11.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("Unable to instantiate ImagesListViewController from the storyboard")
        }
       
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tabEditorialActive"),
            selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tabProfileActive"),
            selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
        
        view.backgroundColor = .ypBlack
        tabBar.barTintColor = .ypBlack
        tabBar.isTranslucent = false
        tabBar.tintColor = .ypWhite
    }
}
