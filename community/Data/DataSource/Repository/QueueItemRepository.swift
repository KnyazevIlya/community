//
//  QueueItemRepository.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation

protocol QueueItemRepository {
    var dataSource: QueueItemDataSource { get set }
    func getUploadItems() async -> Result<[QueueItem], QueueItemError>
    func deleteUploadItem(_ id: String) async -> Result<Bool, QueueItemError>
    func createUploadItem(_ item: UploadItem) async -> Result<Bool, QueueItemError>
}
