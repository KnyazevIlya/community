//
//  MapRouter.swift
//  community
//
//  Created by Illia Kniaziev on 22.02.2022.
//

import UIKit
import CoreLocation
import RxSwift

class MapRouter: Router {
    weak var navigationController: UINavigationController?
    
    required init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    func toSelf() {
        let mapViewModel = MapViewModel(router: self)
        let mapViewController = MapController(viewModel: mapViewModel)
        
        navigationController?.pushViewController(mapViewController, animated: false)
    }
    
    func toPinCreation(with coords: CLLocationCoordinate2D, sendTrigger: PublishSubject<Void>) {
        let creationNavigation = UINavigationController()
        let router = PinCreationRouter(navigationController: creationNavigation, coordinates: coords, sendTrigger: sendTrigger)
        router.toSelf()
        navigationController?.present(creationNavigation, animated: true)
    }
    
    func toQueue() {
        
    }
    
}
