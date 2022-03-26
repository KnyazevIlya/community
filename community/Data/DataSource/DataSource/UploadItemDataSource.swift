//
//  UploadItemDataSource.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

protocol UploadItemDataSource {
    func getAll() async throws -> [UploadItem]
    func getById(_ id: String) async throws -> UploadItem?
    func delete(_ id: String) async throws -> ()
    func create(item: UploadItem) async throws -> ()
//    func update(id: String, item: UploadItem) async throws -> ()
}
