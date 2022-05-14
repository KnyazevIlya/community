//
//  UploadItemDataSourceImpl.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

import Foundation
import CoreData
import UIKit

class UploadItemDataSourceImpl: UploadItemDataSource {
    
    private let mapper: UploadItemMapper
    private var container: NSPersistentContainer
    
    init(container: NSPersistentContainer, mapper: UploadItemMapper) {
        self.mapper = mapper
        self.container = container
    }

    func getAll() throws -> [UploadItem] {
        let request = UploadItemCoreDataEntity.fetchRequest()
        return try container.viewContext
            .fetch(request)
            .map(mapper.map)
    }

    func getById(_ id: String) throws -> UploadItem? {
        guard let coreDataEntity = try getEntityById(id) else { return nil }
        return try mapper.map(from: coreDataEntity)
    }
    
    func getByQueueId(_ queue: String) throws -> [UploadItem] {
        let request = QueueItemCoreDataEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", queue
        )
        let context =  container.viewContext
        let queueItemCoreDataEntity = try context.fetch(request)[0]

        if let result = queueItemCoreDataEntity.uploadItems?.allObjects as? [UploadItemCoreDataEntity] {
            return try result.map(mapper.map)
        }
        
        throw UploadItemError.FetchError
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

    func create(item: UploadItem) throws {
        let coreDataEntity = UploadItemCoreDataEntity(context: container.viewContext)
        mapper.map(from: item, to: coreDataEntity)
        saveContext()
    }
    
    private func getEntityById(_ id: String) throws -> UploadItemCoreDataEntity? {
        let request = UploadItemCoreDataEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "id = %@", id
        )
        let context =  container.viewContext
        let uploadItemCoreDataEntity = try context.fetch(request)[0]
        return uploadItemCoreDataEntity
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
