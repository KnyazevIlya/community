//
//  QueueItemRepository.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation

protocol QueueItemRepository {
    var dataSource: QueueItemDataSource { get set }
    func getQueueItems() -> Result<[QueueItem], QueueItemError>
    func deleteQueueItem(_ id: String) -> Result<Bool, QueueItemError>
    func createQueueItem(_ item: QueueItem) -> Result<Bool, QueueItemError>
}
