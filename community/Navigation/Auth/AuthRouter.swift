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
        let controller = AuthViewController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func toMainFlow() {
        print("go to main flow")
    }
    
}
