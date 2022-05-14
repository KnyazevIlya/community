//
//  CreationAnnotation.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import MapKit

class CreationAnnotation: NSObject, MKAnnotation {
    let title: String? = "Add"
    let coordinate: CLLocationCoordinate2D

    static let reuseIdentifier = String(describing: self)

    init(
        coordinate: CLLocationCoordinate2D
    ) {
        self.coordinate = coordinate

        super.init()
    }
}
