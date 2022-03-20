//
//  PinCreationRouter.swift
//  community
//
//  Created by Illia Kniaziev on 13.03.2022.
//

import UIKit
import CoreLocation
import RxSwift

class PinCreationRouter: Router {
    
    weak var navigationController: UINavigationController?
    var coordinates: CLLocationCoordinate2D!
    var sendTrigger: PublishSubject<Void>!
    
    required init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    convenience init(navigationController: UINavigationController?, coordinates: CLLocationCoordinate2D, sendTrigger: PublishSubject<Void>) {
        self.init(navigationController: navigationController)
        self.coordinates = coordinates
        self.sendTrigger = sendTrigger
    }
    
    func toSelf() {
        let viewModel = PinCreationViewModel(router: self, sendTrigger: sendTrigger)
        viewModel.coordinates = coordinates
        let controller = PinCreationController(viewModel: viewModel)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
    
}
