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
    
    typealias UploadCopletion = (Result<String, StorageUploadError>) -> ()
    typealias FetchCompletion = (Result<Data, StorageFetchError>) -> ()
    
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
    
    enum StorageUploadError: Error {
        
        case dataConvertionFailure
        
        case uploadFailure
        
        case downloadUrlFetchingFailure
        
    }
    
    enum StorageFetchError: Error {
        
        case metadataFetchFailure
        
        case dataFetchFailure
        
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
                completion(.failure(.uploadFailure))
                return
            }
            
            self.storage.child(path).downloadURL { url, error in
                guard let url = url else {
                    completion(.failure(.downloadUrlFetchingFailure))
                    return
                }
                
                completion(.success(url.absoluteString))
            }
        }
    }
    
    func getStorageReferences(forPin pin: Pin, into relay: BehaviorRelay<DataType>) {
        guard let id = pin.id else {
            return
        }
        
        let basePath = "media/\(id)"
        
        storage.child("\(basePath)/image").listAll { result, error in
            guard error == nil else { return }
            
            for item in result.items {
                relay.accept(.image(String(describing: item)))
            }
        }
        
        storage.child("\(basePath)/video").listAll { result, error in
            guard error == nil else { return }

            for item in result.items {
                relay.accept(.video(String(describing: item)))
            }
        }
    }
    
    func fetchData(forRef ref: StorageReference, completion: @escaping FetchCompletion) {
        ref.getMetadata { metadata, error in
            guard let metadata = metadata, error == nil else {
                completion(.failure(.metadataFetchFailure))
                return
            }

            ref.getData(maxSize: metadata.size) { data, error in
                guard let data = data, error == nil else {
                    completion(.failure(.dataFetchFailure))
                    return
                }
             
                completion(.success(data))
            }
        }
    }
    
}
