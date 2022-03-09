//
//  MapRouter.swift
//  community
//
//  Created by Illia Kniaziev on 22.02.2022.
//

import UIKit
import CoreLocation

class MapRouter: Router {
    var navigationController: UINavigationController?
    
    required init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func toSelf() {
        let mapViewModel = MapViewModel(router: self)
        let mapViewController = MapController(viewModel: mapViewModel)
        
        navigationController?.pushViewController(mapViewController, animated: false)
    }
    
    func toPinCreation(with coords: CLLocationCoordinate2D) {
        let creationNavigation = UINavigationController()
        let viewModel = PinCreationViewModel()
        let controller = PinCreationController(viewModel: viewModel)
        creationNavigation.pushViewController(controller, animated: false)
        controller.coordinates = coords
        navigationController?.present(creationNavigation, animated: true)
    }
    
}
