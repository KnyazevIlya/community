//
//  UploadItemRepository.swift
//  community
//
//  Created by Illia Kniaziev on 26.03.2022.
//

import Foundation

protocol UploadItemRepository {
    var dataSource: UploadItemDataSource { get set }
    func getUploadItems() -> Result<[UploadItem], UploadItemError>
    func getUploadItem(id: String) -> Result<UploadItem?, UploadItemError>
    func getUploadItemsByQueue(id: String) -> Result<[UploadItem], UploadItemError>
    func deleteUploadItem(_ id: String) -> Result<Bool, UploadItemError>
    func createUploadItem(_ item: UploadItem) -> Result<Bool, UploadItemError>
}
