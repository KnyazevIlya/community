//
//  QueueItemMapper.swift
//  community
//
//  Created by Illia Kniaziev on 28.03.2022.
//

import Foundation

protocol QueueItemMapper {
    func map(from: QueueItemCoreDataEntity) throws -> QueueItem
    func map(from: QueueItem, to: QueueItemCoreDataEntity)
}
