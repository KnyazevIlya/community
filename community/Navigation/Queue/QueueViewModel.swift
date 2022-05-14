//
//  QueueViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 31.03.2022.
//

import RxSwift
import RxRelay

class QueueViewModel: ViewModel {
    
    let queues: Observable<[QueueItem]>
    
    private var uploadItemRepository: UploadItemRepository
    private var queueItemRepository: QueueItemRepository
    
    init(uploadItemRepository: UploadItemRepository, queueItemRepository: QueueItemRepository) {
        self.uploadItemRepository = uploadItemRepository
        self.queueItemRepository = queueItemRepository
        
        let fetchResult = queueItemRepository.getQueueItems()
        if case .success(let queues) = fetchResult {
            self.queues = Observable.of(queues)
        } else {
            self.queues = Observable.empty()
        }
    }
    
}
