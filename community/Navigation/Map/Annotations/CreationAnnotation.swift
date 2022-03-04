//
//  CreationAnnotation.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import MapKit

class CreationAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    static let reuseIdentifier = String(describing: self)

    init(
        title: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.coordinate = coordinate

        super.init()
    }
}
