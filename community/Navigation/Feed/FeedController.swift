//
//  FeedController.swift
//  community
//
//  Created by Anatoliy Khramchenko on 26.05.2022.
//

import UIKit
import RxSwift

class FeedController: UIViewController {

    @IBOutlet weak var pinsTable: UITableView!
    
    private var pins = [Int:Pin]()
    
    private let itemOffset: CGFloat = 5
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinsTable.register(UINib(nibName: "PinInFeedCell", bundle: nil), forCellReuseIdentifier: PinInFeedCell.cellId)
        pinsTable.delegate = self
        pinsTable.showsVerticalScrollIndicator = false
        
        StorageManager.shared.pins.bind(to: pinsTable.rx.items) { cell, index, pin in
            let cell = cell.dequeueReusableCell(withIdentifier: PinInFeedCell.cellId,for: IndexPath(item: index, section: 0)) as! PinInFeedCell
            cell.uploadData(pin)
            self.pins[index] = pin
            return cell
        }.disposed(by: disposeBag)
    }

}

extension FeedController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let pin = pins[indexPath.row] {
            let viewModel = ViewReportViewModel(pin: pin)
            let controller = ViewReportController(viewModel: viewModel)
            present(controller, animated: true)
        }
    }
    
}
