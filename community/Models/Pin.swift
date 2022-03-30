//
//  Pin.swift
//  community
//
//  Created by Illia Kniaziev on 18.03.2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Pin: Codable {
    @ServerTimestamp var timestamp: Timestamp?
    var id: String
    let name: String
    let description: String
    let coordinates: GeoPoint
}
