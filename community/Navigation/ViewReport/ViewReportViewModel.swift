//
//  ViewReportViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 29.03.2022.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

class ViewReportViewModel: ViewModel {
    
    enum MediaCollectionType {
        case add
        case photo(UIImage?)
        case video(URL)
    }
    
    let locationObservable = PublishRelay<String?>()
    let mediaObservable = BehaviorRelay<[MediaCollectionType]>(value: [.add])
    let pin: Pin
    
    private let disposeBag = DisposeBag()
    
    init(pin: Pin) {
        self.pin = pin
        super.init()
        fetchMedia()
    }
    
    func acceptNewMedia(_ media: MediaCollectionType) {
        mediaObservable.accept([media] + mediaObservable.value)
    }
    
    private func geocodePin() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            let coordinates = CLLocationCoordinate2D(firestoreCoordinates: self.pin.coordinates)
            LocationManager.shared.geocode(coordinates: coordinates) { name in
                DispatchQueue.main.async {
                    self.locationObservable.accept(name)
                }
            }
        }
    }
    
    private func fetchMedia() {
        let referencesRaley = PublishRelay<StorageManager.DataReference>()
        
        StorageManager.shared.getStorageReferences(forPin: pin, into: referencesRaley)
        
        referencesRaley
            .subscribe(onNext: { [weak self] dataRef in
                switch dataRef {
                case .video(let ref):
                    StorageManager.shared.getDownloadUrl(forRef: ref) { result in
                        if case .success(let url) = result {
                            self?.acceptNewMedia(.video(url))
                        }
                    }
                case .image(let ref):
                    StorageManager.shared.fetchData(forRef: ref) { result in
                        if case .success(let data) = result, let image = UIImage(data: data) {
                            self?.acceptNewMedia(.photo(image))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
}
