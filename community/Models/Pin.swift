//
//  Pin.swift
//  community
//
//  Created by Illia Kniaziev on 18.03.2022.
//

import FirebaseFirestore

struct Pin: Codable {
    let name: String
    let description: String
    let coordinates: GeoPoint
    let timestamp: Timestamp
}
