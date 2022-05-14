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
    
    func geocode(coordinates: CLLocationCoordinate2D, completion: @escaping (String?) -> ()) {
        let geocoder = CLGeocoder()
        let location = CLLocation(coordinates: coordinates)
        
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_US")) { placemarks, error in
            guard let currentPlacemark = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            
            completion(
                [
                    currentPlacemark.subLocality,
                    currentPlacemark.thoroughfare,
                    currentPlacemark.locality,
                    currentPlacemark.country,
                ]
                    .compactMap { $0 }
                    .joined(separator: ", ")
            )
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
