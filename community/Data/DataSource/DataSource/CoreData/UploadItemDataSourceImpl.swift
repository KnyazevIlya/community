//
//  UploadItemDataSourceImpl.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

import Foundation
import CoreData

class UploadItemDataSourceImpl: UploadItemDataSource {
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "Community")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func getAll() async throws -> [UploadItem] {
        let request = UploadItemCoreDataEntity.fetchRequest()
        return try container.viewContext
            .fetch(request)
            .map({ coreDataEntity in
                try mapToUploadItem(coreDataEntity)
            })
    }

    func getById(_ id: String) async throws -> UploadItem? {
        guard let coreDataEntity = try getEntityById(id) else { return nil }
        return try mapToUploadItem(coreDataEntity)
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

    func create(item: UploadItem) async throws {
        let coreDataEntity = UploadItemCoreDataEntity(context: container.viewContext)
        let filename: String
        let isImage: Bool
        
        switch item.type {
        case .video(let string):
            filename = string
            isImage = false
        case .image(let string):
            filename = string
            isImage = true
        }
        
        coreDataEntity.data = item.data
        coreDataEntity.filename = filename
        coreDataEntity.isImage = isImage
        coreDataEntity.id = UUID().uuidString
        
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
    
    private func mapToUploadItem(_ item: UploadItemCoreDataEntity) throws -> UploadItem {
        guard let filename = item.filename, let data = item.data else {
            throw UploadItemError.FetchError
        }
        
        let type: StorageManager.DataType
        if item.isImage {
            type = .image(filename)
        } else {
            type = .video(filename)
        }
        
        return UploadItem(type: type, data: data)
    }
    
    private func saveContext(){
            let context = container.viewContext
            if context.hasChanges {
                do{
                    try context.save()
                }catch{
                    fatalError("Error: \(error.localizedDescription)")
                }
            }
        }
    
}
