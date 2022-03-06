//
//  LocationManager.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import CoreLocation
import RxSwift
import RxRelay

final class LocationManager: NSObject {
    static let shared = LocationManager()

    private let manager = CLLocationManager()
    private let currentLocationRelay = BehaviorRelay<CLLocation?>(value: nil)
    
    lazy var currentLocation = currentLocationRelay.asObservable().share(replay: 1, scope: .forever)
    
    func configure() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
    
    deinit {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            currentLocationRelay.accept(lastLocation)
        }
    }
}
