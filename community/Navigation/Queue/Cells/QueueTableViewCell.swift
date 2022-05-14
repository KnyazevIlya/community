//
//  QueueTableViewCell.swift
//  community
//
//  Created by Illia Kniaziev on 31.03.2022.
//

import UIKit
import RxSwift

class QueueTableViewCell: UITableViewCell {

    @IBOutlet weak var statusMark: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    private let disposeBag = DisposeBag()
    private var totalCount = 0
    
    var queue: QueueItem? {
        didSet {
            nameLabel.text = queue?.name
            
            guard let queue = queue,
                  let progress: UploadProgressItem = UserDefaults.getData(forKey: queue.id) else {
                return
            }

            totalCount = progress.totalCount
            uploadCount = progress.uploadedCount
            
            UploadQueueManager.shared.queueEventReceiver
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] event in
                    guard let queue = self?.queue else { return }
                    if case .queueItemFinished(let eventQueueId, _) = event {
                        if eventQueueId == queue.id {
                            self?.uploadCount += 1
                        }
                    }
                })
                .disposed(by: disposeBag)
        }
    }
    
    private var uploadCount = 0 {
        didSet {
            if totalCount > 0 {
                progressBar.setProgress(Float(uploadCount) / Float(totalCount), animated: true)
            }
        }
    }
}
