//
//  StorageManager.swift
//  community
//
//  Created by Illia Kniaziev on 18.03.2022.
//

//TODO: separate class responsibilities into separate enteties to respond to SRP

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import RxRelay
import RxSwift
import CoreLocation
import UIKit

class DataItem {
    let data: Data
    init(data: Data) {
        self.data = data
    }
}

final class StorageManager {
    
    typealias UploadCopletion = (Result<String, StorageUploadError>) -> ()
    typealias FetchCompletion = (Result<Data, StorageFetchError>) -> ()
    typealias DownloadUrlCompletion = (Result<URL, StorageFetchError>) -> ()
    
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
    
    enum DataReference {
        
        case image(StorageReference)
        
        case video(StorageReference)
        
    }
    
    enum StorageUploadError: Error {
        
        case dataConvertionFailure
        
        case uploadFailure
        
        case downloadUrlFetchingFailure
        
    }
    
    enum StorageFetchError: Error {
        
        case metadataFetchFailure
        
        case dataFetchFailure
        
        case downloadUrlFetchFailure
        
    }
    
    static let shared = StorageManager()
    
    private let firestore = Firestore.firestore()
    private let storage = Storage.storage().reference()
    private let cache = NSCache<NSString, DataItem>()
    private var previewReferences = [String : StorageReference]()
    
    private let pinsRelay = PublishRelay<[Pin]>()
    lazy private(set) var pins = pinsRelay.asObservable().share(replay: 1, scope: .forever)
    
    private init() {
        getPins()
    }
    
    //MARK: - Firestore
    /// add a new document to the given collection in firestore
    func createRecord<T: Encodable>(data: T, collection: Collection) {
        let collectionReference = firestore.collection(collection.rawValue)
        do {
            let newReference = try collectionReference.addDocument(from: data)
            print("🟣 A new pin created with ref: \(newReference)")
        } catch {
            print("🔴 Error creating a pin: \(String(describing: error))")
        }
    }
    
    ///establish a firestore subscription to the pins collection
    private func getPins() {
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
    
    //MARK: - Firebase Storage
    ///upload given data to a corresponding path in firebase storage
    func uploadData(path: String, data: Data, completion: @escaping UploadCopletion = {_ in}) {
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
    
    ///fetch and emit references to all images and videos stored in the given pin's folder in firebase storage
    func getStorageReferences(forPin pin: Pin, into relay: PublishRelay<DataReference>) {
        let basePath = "media/\(pin.id)"
        
        storage.child("\(basePath)/image").listAll { [weak self] result, error in
            guard error == nil else { return }
            for item in result.items {
                if self?.previewReferences[pin.id] == nil {
                    self?.previewReferences[pin.id] = item
                }
                relay.accept(.image(item))
            }
        }
        
        storage.child("\(basePath)/video").listAll { result, error in
            guard error == nil else { return }

            for item in result.items {
                relay.accept(.video(item))
            }
        }
    }
    
    func getStorageReference(forPinPreview pin: Pin, completion: @escaping (StorageReference?) -> Void) {
        if let preview = previewReferences[pin.id] {
            completion(preview)
            return
        }
        
        let basePath = "media/\(pin.id)/image"
        
        storage.child(basePath).listAll { [weak self] result, error in
            guard error == nil else {
                completion(nil)
                return
            }
            
            if let firstImage = result.items.first {
                self?.previewReferences[pin.id] = firstImage
                completion(firstImage)
            } else {
                completion(nil)
            }
        }
    }
    
    func getStorageReference(forUserId userId: String) -> StorageReference {
        return storage.child("users/\(userId)")
    }
    
    ///download a file from a given firebase storage reference
    func fetchData(forRef ref: StorageReference, completion: @escaping FetchCompletion) {
        if let cachedItem = cache.object(forKey: NSString(string: ref.fullPath)) {
            completion(.success(cachedItem.data))
            return
        }
        
        ref.getMetadata { metadata, error in
            guard let metadata = metadata, error == nil else {
                completion(.failure(.metadataFetchFailure))
                return
            }

            ref.getData(maxSize: metadata.size) { [weak self] data, error in
                guard let data = data, error == nil else {
                    completion(.failure(.dataFetchFailure))
                    return
                }
                
                self?.cache.setObject(DataItem(data: data), forKey: NSString(string: ref.fullPath))
                completion(.success(data))
            }
        }
    }
    
    func getDownloadUrl(forRef ref: StorageReference, completion: @escaping DownloadUrlCompletion) {
        ref.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(.downloadUrlFetchFailure))
                return
            }

            completion(.success(url))
        }
    }
    
}
