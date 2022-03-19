//
//  Pin.swift
//  community
//
//  Created by Illia Kniaziev on 18.03.2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct Pin: Codable {
    @DocumentID var id: String?
    @ServerTimestamp var timestamp: Timestamp?
    let name: String
    let description: String
    let coordinates: GeoPoint
//    let uuid: String
}
