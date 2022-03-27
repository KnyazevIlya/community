//
//  QueueItemDataSource.swift
//  community
//
//  Created by Illia Kniaziev on 27.03.2022.
//

import Foundation

protocol QueueItemDataSource {
    func getAll() async throws -> [QueueItem]
    func delete(_ id: String) async throws -> ()
    func create(item: QueueItem) async throws -> ()
}
