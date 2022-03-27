//
//  UploadItemDataSource.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

protocol UploadItemDataSource {
    func getAll() throws -> [UploadItem]
    func getById(_ id: String) throws -> UploadItem?
    func getByQueueId(_ queue: String) throws -> [UploadItem]
    func delete(_ id: String) throws -> ()
    func create(item: UploadItem) throws -> ()
//    func update(id: String, item: UploadItem) async throws -> ()
}
