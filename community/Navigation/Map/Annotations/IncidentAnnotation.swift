//
//  IncidentAnnotation.swift
//  community
//
//  Created by Illia Kniaziev on 19.03.2022.
//

import MapKit

class IncidentAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let pin: Pin

    static let reuseIdentifier = String(describing: self)

    init(pin: Pin) {
        coordinate = CLLocationCoordinate2D(latitude: pin.coordinates.latitude, longitude: pin.coordinates.longitude)
        title = pin.name
        subtitle = pin.description
        self.pin = pin
        
        super.init()
    }
}
