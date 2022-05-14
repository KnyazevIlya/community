//
//  Application.swift
//  community
//
//  Created by Illia Kniaziev on 18.02.2022.
//

import UIKit
import DropDown

class Application {
    
    static let shared = Application()
    
    private init() {
        LocationManager.shared.configure()
        UploadQueueManager.shared.synchronizeQueue()
    }
    
    func prepareInitialScreen(in window: UIWindow?) {
        let navigationController = UINavigationController()
        
        if GoogleAuthManager.shared.restoreUser() {
            let tabBar = TabBarController(initialTab: .map)
            navigationController.pushViewController(tabBar, animated: false)
        } else {
            let router = AuthRouter(navigationController: navigationController)
            router.toSelf()
        }
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    func configureDropDown() {
        DropDown.startListeningToKeyboard()
        DropDown.appearance().backgroundColor = .mainGray
        DropDown.appearance().textColor = .secondaryGray
        DropDown.appearance().selectionBackgroundColor = .secondaryGray
        DropDown.appearance().selectedTextColor = .mainGray
    }
}
