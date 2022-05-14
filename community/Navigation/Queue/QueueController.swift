//
//  QueueController.swift
//  community
//
//  Created by Illia Kniaziev on 31.03.2022.
//

import UIKit
import RxSwift

class QueueController: ViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel: QueueViewModel
    
    let disposeBag = DisposeBag()
    
    init(viewModel: QueueViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(QueueTableViewCell.self)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel.queues
            .bind(to: tableView.rx.items) { tableView, index, queue in
                let cell = tableView.dequeueReusableCell(withIdentifier: QueueTableViewCell.identifier, for: IndexPath(row: index, section: 0)) as! QueueTableViewCell
                cell.queue = queue
                return cell
            }
            .disposed(by: disposeBag)
    }
    
}
