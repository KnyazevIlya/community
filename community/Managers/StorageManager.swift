//
//  StorageManager.swift
//  community
//
//  Created by Illia Kniaziev on 18.03.2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import RxRelay
import RxSwift
import CoreLocation

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let db = Firestore.firestore()
    private let collection = "pins"
    
    private let pinsRelay = BehaviorRelay<[Pin]>(value: [])
    lazy private(set) var pins = pinsRelay.asObservable().share(replay: 1, scope: .forever)
    
    private init() {
        getPins()
    }
    
    func getPins() {
        db.collection(collection).addSnapshotListener { [weak self] querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("🔴 Error fetching pins: \(String(describing: error))")
                return
            }
            
            self?.pinsRelay.accept(
                documents.compactMap { document in
                    try? document.data(as: Pin.self)
                }
            )
        }
    }
}
