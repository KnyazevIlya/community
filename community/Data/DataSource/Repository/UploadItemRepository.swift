//
//  UploadItemRepository.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

import Foundation

protocol UploadItemRepository {
    var dataSource: UploadItemDataSource { get set }
    func getUploadItems() async -> Result<[UploadItem], UploadItemError>
    func getUploadItem(id: String) async -> Result<UploadItem? , UploadItemError>
    func deleteUploadItem(_ id: String) async -> Result<Bool, UploadItemError>
    func createUploadItem(_ item: UploadItem) async -> Result<Bool, UploadItemError>
}
