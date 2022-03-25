//
//  UploadDataItem.swift
//  community
//
//  Created by Illia Kniaziev on 23.03.2022.
//

import Foundation

struct UploadDataItem {
    let type: StorageManager.DataType
    let data: Data
}

class UploadDataItems {
    var items: [UploadDataItem] = []
    
    init(items: [UploadDataItem]) {
        self.items = items
    }
}
