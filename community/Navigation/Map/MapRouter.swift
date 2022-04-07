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
    
    func toReportViewer(pin: Pin) {
        let viewModel = ViewReportViewModel(pin: pin)
        let controller = ViewReportController(viewModel: viewModel)
        navigationController?.present(controller, animated: true)
    }
    
    func toQueue() {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let queueItemMapper = QueueItemMapperImpl()
        let uploadItemMapper = UploadItemMapperImpl()
        let queueDataSource = QueueItemDataSourceImpl(container: container, queueItemMapper: queueItemMapper, uploadItemMapper: uploadItemMapper)
        let queueItemRepository = QueueItemRepositoryImpl(dataSource: queueDataSource)
        let uploadDataSource = UploadItemDataSourceImpl(container: container, mapper: uploadItemMapper)
        let uploadItemRepository = UploadItemRepositoryImpl(dataSource: uploadDataSource)
        
        let viewModel = QueueViewModel(uploadItemRepository: uploadItemRepository, queueItemRepository: queueItemRepository)
        let controller = QueueController(viewModel: viewModel)
        
        navigationController?.present(controller, animated: true)
    }
    
}
