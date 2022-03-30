//
//  ViewReportViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 29.03.2022.
//

import Foundation
import CoreLocation
import RxCocoa

class ViewReportViewModel: ViewModel {
    
    var pin: Pin {
        didSet {
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
    }
    
    let locationObservable = PublishRelay<String?>()
    
    init(pin: Pin) {
        self.pin = pin
    }
    
}
