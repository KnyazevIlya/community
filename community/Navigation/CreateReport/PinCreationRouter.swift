//
//  PinCreationRouter.swift
//  community
//
//  Created by Illia Kniaziev on 13.03.2022.
//

import UIKit
import CoreLocation

class PinCreationRouter: Router {
    
    var navigationController: UINavigationController?
    var coordinates: CLLocationCoordinate2D!
    
    required init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    convenience init(navigationController: UINavigationController?, coordinates: CLLocationCoordinate2D) {
        self.init(navigationController: navigationController)
        self.coordinates = coordinates
    }
    
    func toSelf() {
        let viewModel = PinCreationViewModel(router: self)
        viewModel.coordinates = coordinates
        let controller = PinCreationController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
    
}
