//
//  AuthRouter.swift
//  community
//
//  Created by Illia Kniaziev on 21.02.2022.
//

import UIKit

class AuthRouter: Router {
    weak var navigationController: UINavigationController?
    
    required init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func toSelf() {
        let viewModel = AuthViewModel(router: self)
        let controller = AuthController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func toMainFlow() {
        guard let navigationController = navigationController else {
            return
        }
        
        var controllers = navigationController.viewControllers
        controllers.remove(at: 0)
        navigationController.viewControllers = controllers
        
        let controller = TabBarController(initialTab: .map)
        navigationController.pushViewController(controller, animated: true)
    }
    
}
