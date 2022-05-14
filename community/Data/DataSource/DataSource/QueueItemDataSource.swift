//
//  QueueItemDataSource.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation

protocol QueueItemDataSource {
    func getAll() throws -> [QueueItem]
    func set(item: UploadItem, forQueueId queueId: String) throws -> ()
    func delete(_ id: String) throws -> ()
    func create(item: QueueItem) throws -> ()
}
