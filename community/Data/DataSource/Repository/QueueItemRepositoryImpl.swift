//
//  QueueItemRepositoryImpl.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation

class QueueItemRepositoryImpl: QueueItemRepository {
    
    var dataSource: QueueItemDataSource
    
    init(dataSource: QueueItemDataSource) {
        self.dataSource = dataSource
    }
    
    func getQueueItems() -> Result<[QueueItem], QueueItemError> {
        do {
            let items = try dataSource.getAll()
            return .success(items)
        } catch {
            return .failure(.FetchError)
        }
    }
    
    func set(item: UploadItem, forQueueId queueID: String) -> Result<Bool, QueueItemError> {
        do {
            try dataSource.set(item: item, forQueueId: queueID)
            return .success(true)
        } catch {
            return .failure(.CreateError)
        }
    }
    
    func deleteQueueItem(_ id: String) -> Result<Bool, QueueItemError> {
        do {
            try dataSource.delete(id)
            return .success(true)
        } catch {
            return .failure(.DeleteError)
        }
    }
    
    func createQueueItem(_ item: QueueItem) -> Result<Bool, QueueItemError> {
        do {
            try dataSource.create(item: item)
            return .success(true)
        } catch {
            return .failure(.CreateError)
        }
    }
    
    
}
