//
//  MapViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 22.02.2022.
//

import RxSwift
import RxCocoa
import CoreLocation

class MapViewModel: ViewModel {
    
    let pinTrigger = PublishSubject<CLLocationCoordinate2D>()
    
    private let router: MapRouter
    private let disposeBag = DisposeBag()
    
    init(router: MapRouter) {
        self.router = router
        super.init()
        
        pinTrigger
            .subscribe(onNext: { [weak self] coords in
                self?.router.toPinCreation(with: coords)
            })
            .disposed(by: disposeBag)
    }
    
}
