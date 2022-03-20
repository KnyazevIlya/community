//
//  PinCreationViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import RxSwift
import RxCocoa
import CoreLocation
import FirebaseFirestore

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
    
    weak var sendTrigger: PublishSubject<Void>?
    let nameRelay = BehaviorRelay<String>(value: "")
    let descriptionRelay = BehaviorRelay<String>(value: "")
    
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
    
    init(router: PinCreationRouter, sendTrigger: PublishSubject<Void>) {
        self.router = router
        self.sendTrigger = sendTrigger
    }
    
    func acceptNewMedia(_ media: MediaCollectionType) {
        mediaObservable.accept([.add, media] + mediaObservable.value[1...])
        router.dismiss()
    }
    
    func transform(_ input: Input) -> Output {
//        let sendTapped = Driver.combineLatest(input.sendTap, input.nameText, input.descriptionText)
//            .do(onNext: { [weak self] textData in
//                guard let self = self, let name = textData.1 else { return }
//
//                let pin = Pin(
//                    name: name,
//                    description: textData.2 ?? "",
//                    coordinates: GeoPoint(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude)
//                )
//                StorageManager.shared.createRecord(data: pin, collectionName: "pins")
//                self.sendTrigger?.on(.next(()))
//            })
        
        let sendTapped = input.sendTap
            .do(onNext: { [weak self] in
                guard let self = self, !self.nameRelay.value.isEmpty else { return }
                
                let pin = Pin(
                    name: self.nameRelay.value,
                    description: self.descriptionRelay.value,
                    coordinates: GeoPoint(latitude: self.coordinates.latitude, longitude: self.coordinates.longitude)
                )
                StorageManager.shared.createRecord(data: pin, collectionName: "pins")
                self.sendTrigger?.on(.next(()))
            })
        
        return Output(
            sendTapped: sendTapped
        )
    }
    
}
