//
//  MapViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 22.02.2022.
//

import RxSwift
import RxCocoa
import CoreLocation

class MapViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let queueTap: Driver<Void>
    }
    
    struct Output {
        let queueTapped: Driver<Void>
    }
    
    let pinTrigger = PublishSubject<CLLocationCoordinate2D>()
    let sendTrigger = PublishSubject<Void>()
    
    private let router: MapRouter
    private let disposeBag = DisposeBag()
    
    init(router: MapRouter) {
        self.router = router
        super.init()
        
        pinTrigger
            .subscribe(onNext: { [weak self] coords in
                guard let self = self else { return }
                self.router.toPinCreation(with: coords, sendTrigger: self.sendTrigger)
            })
            .disposed(by: disposeBag)
    }
    
    func transform(_ input: Input) -> Output {
        let queueTapped = input.queueTap
            .do(onNext: router.toQueue)
        
        return Output(queueTapped: queueTapped)
    }
    
}
