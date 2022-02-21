//
//  Application.swift
//  community
//
//  Created by Illia Kniaziev on 18.02.2022.
//

import UIKit


class Application {
    
    static let shared = Application()
    
    private init() {}
    
    func prepareInitialScreen(in window: UIWindow?) {
        let navigationController = UINavigationController()
        
        if GoogleAuthManager.shared.restoreUser() {
            let tabBar = TabBarController(initialTab: .map)
            navigationController.pushViewController(tabBar, animated: false)
        } else {
            let router = AuthRouter(navigationController: navigationController)
            router.toSelf()
        }
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
