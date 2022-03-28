//
//  UploadItemMapper.swift
//  community
//
//  Created by Illia Kniaziev on 28.03.2022.
//

import Foundation

protocol UploadItemMapper {
    func map(from: UploadItemCoreDataEntity) throws -> UploadItem
    func map(from: UploadItem, to: UploadItemCoreDataEntity)
}
