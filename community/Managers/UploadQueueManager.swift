//
//  UploadQueueManager.swift
//  community
//
//  Created by Illia Kniaziev on 22.03.2022.
//

import Foundation
import UIKit

final class UploadQueueManager {
    
    static let shared = UploadQueueManager()
    
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
    
    ///Start uploading of all peding queues
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
            for (itemIndex, uploadItem) in uploadItems.enumerated() {
                uploadQueue.async {
                    self.semaphore.wait()
                    print("🔵Start queue: \(queue.id); item: \(uploadItem.id); index: \(itemIndex)")
                    StorageManager.shared.uploadData(pinId: queue.id, data: uploadItem.data, type: uploadItem.type) { [weak self] _ in
                        _ = self?.uploadItemRepository.deleteUploadItem(uploadItem.id)
                        
                        if itemIndex == uploadItems.count - 1 {
                            let qres = self?.queueItemRepository.deleteQueueItem(queue.id)
                            print("🟣🟣🟣Finish queue: \(queue.id); res: \(String(describing: qres))")
                        }
                        print("🟣Finish queue: \(queue.id); item: \(uploadItem.id); index: \(itemIndex)")
                        self?.semaphore.signal()
                    }
                }
            }
        }
    }

}
