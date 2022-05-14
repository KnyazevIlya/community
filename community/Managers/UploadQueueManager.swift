//
//  UploadQueueManager.swift
//  community
//
//  Created by Illia Kniaziev on 22.03.2022.
//

import Foundation
import UIKit
import RxRelay

final class UploadQueueManager {
    
    enum QueueEvent {
        
        case queueStarted(String)
        
        case queueItemFinished(String, Bool)
        
        case queueFinished(String)
        
    }
    
    static let shared = UploadQueueManager()
    
    let queueEventReceiver = PublishRelay<QueueEvent>()
    
    private var uploadItemRepository: UploadItemRepository
    private var queueItemRepository: QueueItemRepository

    private let uploadQueue = DispatchQueue(label: "UploadQueue", qos: .utility, attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 3)
    private var isBusy = false

    private init() {
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let queueItemMapper = QueueItemMapperImpl()
        let uploadItemMapper = UploadItemMapperImpl()
        let queueDataSource = QueueItemDataSourceImpl(container: container, queueItemMapper: queueItemMapper, uploadItemMapper: uploadItemMapper)
        queueItemRepository = QueueItemRepositoryImpl(dataSource: queueDataSource)
        
        let uploadDataSource = UploadItemDataSourceImpl(container: container, mapper: uploadItemMapper)
        uploadItemRepository = UploadItemRepositoryImpl(dataSource: uploadDataSource)
    }
    
    ///Start uploading of all pending queues
    func synchronizeQueue() {
        if case .success(let queues) = queueItemRepository.getQueueItems() {
            for queue in queues {
                uploadQueueItems(queue)
            }
        }
    }
    
    ///Start loading of a given queue
    func uploadQueueItems(_ queue: QueueItem) {
        if case .success(let uploadItems) = uploadItemRepository.getUploadItemsByQueue(id: queue.id) {
            if UserDefaults.standard.value(forKey: queue.id) == nil {
                let progress = UploadProgressItem(uploadedCount: 0, totalCount: uploadItems.count)
                UserDefaults.saveData(of: progress, forKey: queue.id)
            }
            
            for (itemIndex, uploadItem) in uploadItems.enumerated() {
                uploadQueue.async { [weak self] in
                    self?.semaphore.wait()
                    
                    self?.queueEventReceiver.accept(.queueStarted(queue.id))
                    StorageManager.shared.uploadData(path: uploadItem.type.getPath(pinId: queue.id) , data: uploadItem.data) { res in
                        _ = self?.uploadItemRepository.deleteUploadItem(uploadItem.id)
                        
                        if itemIndex == uploadItems.count - 1 {
                            self?.queueEventReceiver.accept(.queueFinished(queue.id))
                            _ = self?.queueItemRepository.deleteQueueItem(queue.id)
                            UserDefaults.remove(forKey: queue.id)
                        }
                        
                        var isSucceded = false
                        if case .success(_) = res {
                            isSucceded = true
                        }
                        
                        if var record: UploadProgressItem = UserDefaults.getData(forKey: queue.id) {
                            record.uploadedCount += 1
                            UserDefaults.saveData(of: record, forKey: queue.id)
                        }
                        
                        self?.queueEventReceiver.accept(.queueItemFinished(queue.id, isSucceded))
                        self?.semaphore.signal()
                    }
                }
            }
        }
    }

}
