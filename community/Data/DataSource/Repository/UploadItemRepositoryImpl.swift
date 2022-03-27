//
//  UploadItemRepositoryImpl.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

import Foundation

class UploadItemRepositoryImpl: UploadItemRepository {
    
    var dataSource: UploadItemDataSource
    
    init(dataSource: UploadItemDataSource) {
        self.dataSource = dataSource
    }
    
    func getUploadItems() -> Result<[UploadItem], UploadItemError> {
        do {
            let items = try dataSource.getAll()
            return .success(items)
        } catch {
            return .failure(.FetchError)
        }
    }
    
    func getUploadItem(id: String) -> Result<UploadItem?, UploadItemError> {
        do {
            let item = try dataSource.getById(id)
            return .success(item)
        } catch {
            return .failure(.FetchError)
        }
    }
    
    func getUploadItemsByQueue(id: String) -> Result<[UploadItem], UploadItemError> {
        do {
            let items = try dataSource.getByQueueId(id)
            return .success(items)
        } catch {
            return .failure(.FetchError)
        }
    }
    
    func deleteUploadItem(_ id: String) -> Result<Bool, UploadItemError> {
        do {
            try dataSource.delete(id)
            return .success(true)
        } catch {
            return .failure(.DeleteError)
        }
    }
    
    func createUploadItem(_ item: UploadItem) -> Result<Bool, UploadItemError> {
        do {
            try dataSource.create(item: item)
            return .success(true)
        } catch {
            return .failure(.CreateError)
        }
    }
    
}
