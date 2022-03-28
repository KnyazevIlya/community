//
//  UploadItemMapperImpl.swift
//  community
//
//  Created by Illia Kniaziev on 28.03.2022.
//

import Foundation

class UploadItemMapperImpl: UploadItemMapper {
    
    func map(from item: UploadItemCoreDataEntity) throws -> UploadItem {
        guard let filename = item.filename, let data = item.data else {
            throw UploadItemError.MapError
        }
        
        let type: StorageManager.DataType
        if item.isImage {
            type = .image(filename)
        } else {
            type = .video(filename)
        }
        
        return UploadItem(type: type, data: data)
    }
    
    func map(from model: UploadItem, to coreEntity: UploadItemCoreDataEntity) {
        let filename: String
        let isImage: Bool
        
        switch model.type {
        case .video(let string):
            filename = string
            isImage = false
        case .image(let string):
            filename = string
            isImage = true
        }
        
        coreEntity.data = model.data
        coreEntity.filename = filename
        coreEntity.isImage = isImage
        coreEntity.id = UUID().uuidString
    }
    
}
