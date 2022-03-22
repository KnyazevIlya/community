//
//  StorageManager.swift
//  community
//
//  Created by Illia Kniaziev on 18.03.2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import RxRelay
import RxSwift
import CoreLocation
import UIKit

final class StorageManager {
    
    typealias UploadCopletion = (Result<String, Error>) -> ()
    
    enum Collection: String {
        
        case pins = "pins"
        
    }
    
    enum DataType {
        
        case image(String)
        
        case video(String)
        
        private var root: String {
            "media"
        }
        
        func getPath(pinId: String) -> String {
            var subfolder = ""
            var filename = ""
            
            switch self {
            case .image(let string):
                subfolder = "image"
                filename = string
            case .video(let string):
                subfolder = "video"
                filename = string
            }
            
            return "\(root)/\(pinId)/\(subfolder)/\(filename)"
        }
        
    }
    
    enum UploadError: Error {
        
        case dataConvertionFailure
        
        case uploadFailure
        
        case downloadUrlFetchingFailure
        
    }
    
    static let shared = StorageManager()
    
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage().reference()
    
    private let pinsRelay = BehaviorRelay<[Pin]>(value: [])
    lazy private(set) var pins = pinsRelay.asObservable().share(replay: 1, scope: .forever)
    
    private init() {
        getPins()
    }
    
    func getPins() {
        firestore.collection(Collection.pins.rawValue).addSnapshotListener { [weak self] querySnapshot, error in
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
    
    func createRecord<T: Encodable>(data: T, collection: Collection) {
        let collectionReference = firestore.collection(collection.rawValue)
        do {
            let newReference = try collectionReference.addDocument(from: data)
            print("🟣 A new pin created with ref: \(newReference)")
        } catch {
            print("🔴 Error creating a pin: \(String(describing: error))")
        }
    }
    
    func uploadData(pinId: String, data: Data, type: DataType, completion: @escaping UploadCopletion) {
        let path = type.getPath(pinId: pinId)
        
        storage.child(path).putData(data, metadata: nil) { metadata, error in
            guard error == nil else {
                completion(.failure(UploadError.uploadFailure))
                return
            }
            
            self.storage.child(path).downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(UploadError.downloadUrlFetchingFailure))
                    return
                }
                
                completion(.success(url.absoluteString))
            }
        }
    }
}
