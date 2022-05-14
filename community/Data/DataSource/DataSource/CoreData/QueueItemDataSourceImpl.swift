//
//  QueueItemDataSourceImpl.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation
import CoreData
import UIKit

class QueueItemDataSourceImpl: QueueItemDataSource {
    
    private let queueItemMapper: QueueItemMapper
    private let uploadItemMapper: UploadItemMapper
    private var container: NSPersistentContainer
    
    init(container: NSPersistentContainer, queueItemMapper: QueueItemMapper, uploadItemMapper:UploadItemMapper) {
        self.queueItemMapper = queueItemMapper
        self.uploadItemMapper = uploadItemMapper
        self.container = container
    }
    
    func getAll() throws -> [QueueItem] {
        let request = QueueItemCoreDataEntity.fetchRequest()
        let sorting = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sorting]
        
        return try container.viewContext
            .fetch(request)
            .map(queueItemMapper.map)
    }
    
    func set(item: UploadItem, forQueueId queueID: String) throws {
        guard let queueItem = try? getEntityById(queueID) else {
            throw QueueItemError.FetchError
        }
        
        let uploadCoreDataEntity = UploadItemCoreDataEntity(context: container.viewContext)
        uploadItemMapper.map(from: item, to: uploadCoreDataEntity)
        uploadCoreDataEntity.queueItem = queueItem
        
        saveContext()
    }
    
    func delete(_ id: String) throws {
        let coreDataEntity = try getEntityById(id)!
        let context = container.viewContext
        context.delete(coreDataEntity)
        do {
            try context.save()
        } catch {
            context.rollback()
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func create(item: QueueItem) throws {
        let coreDataEntity = QueueItemCoreDataEntity(context: container.viewContext)
        queueItemMapper.map(from: item, to: coreDataEntity)
        saveContext()
    }

    private func getEntityById(_ id: String) throws -> QueueItemCoreDataEntity? {
        let request = QueueItemCoreDataEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id
        )
        let context =  container.viewContext
        let queueItemCoreDataEntity = try context.fetch(request)[0]
        return queueItemCoreDataEntity
    }
    
    private func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
}
