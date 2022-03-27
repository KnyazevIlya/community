//
//  QueueItemDataSourceImpl.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation
import CoreData

class QueueItemDataSourceImpl: QueueItemDataSource {
    
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "Community")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func getAll() async throws -> [QueueItem] {
        let request = QueueItemCoreDataEntity.fetchRequest()
        let sorting = NSSortDescriptor(key: "timestamp", ascending: false)
        request.sortDescriptors = [sorting]
        
        return try container.viewContext
            .fetch(request)
            .map(mapToQueueItem)
    }
    
    func delete(_ id: String) async throws {
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
    
    func create(item: QueueItem) async throws {
        let coreDataEntity = QueueItemCoreDataEntity(context: container.viewContext)
        
        coreDataEntity.id = item.id
        coreDataEntity.timestamp = item.timestamp
        
        saveContext()
    }
    
    private func mapToQueueItem(_ item: QueueItemCoreDataEntity) throws -> QueueItem {
        guard let id = item.id, let timestamp = item.timestamp else {
            throw QueueItemError.FetchError
        }
        
        return QueueItem(
            id: id,
            timestamp: timestamp
        )
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
