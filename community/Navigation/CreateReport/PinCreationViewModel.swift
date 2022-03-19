//
//  PinCreationViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import RxSwift
import RxCocoa
import CoreLocation

class PinCreationViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let sendTap: Driver<Void>
    }
    
    struct Output {
        let sendTapped: Driver<Void>
    }
    
    enum MediaCollectionType {
        case add
        case photo(UIImage?)
        case video(URL)
    }
    
    var coordinates: CLLocationCoordinate2D! {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                LocationManager.shared.geocode(coordinates: self.coordinates) {
                    self.locationObservable.accept($0)
                }
            }
        }
    }
    
    let mediaObservable = BehaviorRelay<[MediaCollectionType]>(value: [.add])
    let locationObservable = PublishRelay<String?>()
    private var router: PinCreationRouter!
    
    init(router: PinCreationRouter) {
        self.router = router
    }
    
    func acceptNewMedia(_ media: MediaCollectionType) {
        mediaObservable.accept([.add, media] + mediaObservable.value[1...])
        router.dismiss()
    }
    
    func transform(_ input: Input) -> Output {
        let sendTapped = input.sendTap
            .do(onNext: {
                
            })
        
        return Output(sendTapped: sendTapped)
    }
    
}
