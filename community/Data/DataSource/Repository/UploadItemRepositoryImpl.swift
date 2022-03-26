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
    
    func getUploadItems() async -> Result<[UploadItem], UploadItemError> {
        do {
            let items = try await dataSource.getAll()
            return .success(items)
        } catch {
            return .failure(.FetchError)
        }
    }
    
    func getUploadItem(id: String) async -> Result<UploadItem?, UploadItemError> {
        do {
            let item = try await dataSource.getById(id)
            return .success(item)
        } catch {
            return .failure(.FetchError)
        }
    }
    
    func deleteUploadItem(_ id: String) async -> Result<Bool, UploadItemError> {
        do {
            try await dataSource.delete(id)
            return .success(true)
        } catch {
            return .failure(.DeleteError)
        }
    }
    
    func createUploadItem(_ item: UploadItem) async -> Result<Bool, UploadItemError> {
        do {
            try await dataSource.create(item: item)
            return .success(true)
        } catch {
            return .failure(.CreateError)
        }
    }
    
}
