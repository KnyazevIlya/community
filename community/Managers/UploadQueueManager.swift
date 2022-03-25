//
//  UploadQueueManager.swift
//  community
//
//  Created by Illia Kniaziev on 22.03.2022.
//

import Foundation

final class UploadQueueManager {
    
    static let shared = UploadQueueManager()
    
    /* private */let cache = NSCache<NSString, UploadDataItems>()
    private let queue = DispatchQueue(label: "UploadQueue", qos: .utility, attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 3)
    private var isBusy = false
    
    private init() {
        synchronizeQueue()
    }
    
    func cache(value: UploadDataItems, forKey key: NSString) {
        cache.setObject(value, forKey: key)
    }
    
    func synchronizeQueue() {
        if isBusy { return }
        print("0️⃣")
        isBusy = true
        if var uploadQueueIds: [String] = UserPreferences.uploadQueue.getData() {
            print("1️⃣", uploadQueueIds)
            for (idIndex, id) in uploadQueueIds.enumerated() {
                print("2️⃣", id)
                print(cache.object(forKey: NSString(string: id)))
                if let mediaItems = cache.object(forKey: NSString(string: id)) {
                    print("3️⃣", mediaItems)
                    var mediaItemsCollection = mediaItems.items
                    for (index, mediaItem) in mediaItemsCollection.enumerated() {
                        print("4️⃣", index, mediaItem)
                        queue.async { [unowned self] in
                            self.semaphore.wait()
                            StorageManager.shared.uploadData(pinId: id, data: mediaItem.data, type: mediaItem.type) { result in
                                switch result {
                                case .success(_):
                                    mediaItemsCollection.remove(at: index)
                                    mediaItems.items = mediaItemsCollection
                                    cache.setObject(mediaItems, forKey: NSString(string: id))
                                case .failure(_):
                                    break
                                }
                                
                                if index == mediaItemsCollection.count - 1 {
                                    mediaItems.items = mediaItemsCollection
                                    cache.removeObject(forKey: NSString(string: id))
                                    uploadQueueIds.remove(at: idIndex)
                                    UserPreferences.uploadQueue.saveData(of: uploadQueueIds)
                                    self.isBusy = false
                                }
                                
                                semaphore.signal()
                            }
                        }
                    }
                } else {
                    isBusy = false
                }
            }
        } else {
            isBusy = false
        }
    }
    
}
