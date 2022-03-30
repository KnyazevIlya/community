//
//  CoreLocation+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 08.03.2022.
//

import CoreLocation
import FirebaseFirestore

extension CLLocation {
    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}

extension CLLocationCoordinate2D {
    init(firestoreCoordinates coordinates: GeoPoint) {
        self.init(latitude: coordinates.latitude, longitude: coordinates.longitude)
    }
}
