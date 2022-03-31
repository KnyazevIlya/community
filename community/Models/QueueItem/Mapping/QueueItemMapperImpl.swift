//
//  QueueItemMapperImpl.swift
//  community
//
//  Created by Illia Kniaziev on 28.03.2022.
//

import Foundation

class QueueItemMapperImpl: QueueItemMapper {
    
    func map(from item: QueueItemCoreDataEntity) throws -> QueueItem {
        guard let id = item.id, let name = item.name, let timestamp = item.timestamp else {
            throw QueueItemError.MapError
        }
        
        return QueueItem(
            id: id,
            name: name,
            timestamp: timestamp
        )
    }
    
    func map(from model: QueueItem, to coreEntity: QueueItemCoreDataEntity) {
        coreEntity.id = model.id
        coreEntity.name = model.name
        coreEntity.timestamp = model.timestamp
    }
    
}
