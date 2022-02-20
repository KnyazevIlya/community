//
//  TabBarConntroller.swift
//  community
//
//  Created by Illia Kniaziev on 20.02.2022.
//

import UIKit

class TabBarController: UITabBarController {
    
    enum Tab: Int {
        case feed
        case map
        case profile
    }
    
    private var initialTab: Tab
    
    init(tab: Tab) {
        self.initialTab = tab
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("🟢 \(#function) \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .systemGray5
        tabBar.unselectedItemTintColor = .white
        view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewControllers?.removeAll()
    }
    
    static func tabBarController(initialTab tab: Tab) -> TabBarController {
        let tabBarController = TabBarController(tab: tab)
        
        let feedNavigation = UINavigationController()
        let feedController = UIViewController()
        feedController.view.backgroundColor = .systemBlue
        feedNavigation.pushViewController(feedController, animated: false)
        
        let mapNavigation = UINavigationController()
        let mapViewController = UIViewController()
        mapViewController.view.backgroundColor = .systemGreen
        mapNavigation.pushViewController(mapViewController, animated: false)
        
        let profileNavigation = UINavigationController()
        let profileViewController = UIViewController()
        profileViewController.view.backgroundColor = .systemPink
        profileNavigation.pushViewController(profileViewController, animated: false)
        
        tabBarController.viewControllers = [
            feedNavigation,
            mapNavigation,
            profileNavigation
        ]
        
        tabBarController.selectedIndex = tab.rawValue
        
        setTabBarItem(
            title: "Feed",
            image: UIImage(systemName: "flame"),
            selectedImage: UIImage(systemName: "flame.fill"),
            tag: 1,
            vc: feedNavigation,
            current: tab == .feed
        )
        
        setTabBarItem(
            title: "Area",
            image: UIImage(systemName: "map"),
            selectedImage: UIImage(systemName: "map.fill"),
            tag: 2,
            vc: mapNavigation,
            current: tab == .map
        )
        
        setTabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill"),
            tag: 3,
            vc: profileNavigation,
            current: tab == .profile
        )
        
        return tabBarController
    }
    
    static private func setTabBarItem(title: String? = nil, image: UIImage?, selectedImage: UIImage?, tag: Int, vc: UIViewController?, current: Bool) {
        
        let item = UITabBarItem(
            title: title,
            image: image?.withRenderingMode(.alwaysTemplate),
            selectedImage: selectedImage?.withRenderingMode(.alwaysTemplate)
        )
        
        item.tag = tag
        vc?.tabBarItem = item
    }
}

