//
//  FeedController.swift
//  community
//
//  Created by Anatoliy Khramchenko on 26.05.2022.
//

import UIKit
import RxSwift

class FeedController: UIViewController {
    
    //drop-down list
    @IBOutlet weak var dropDownListTable: UITableView!
    @IBOutlet weak var dropDownListButton: UIButton!
    @IBOutlet weak var dropDownListArrowImage: UIImageView!
    private var dropDownListModel: DropDownListModel!
    
    @IBOutlet weak var pinsTable: UITableView!
    
    private var pins = [Int:Pin]()
    
    private let itemOffset: CGFloat = 5
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //init table
        pinsTable.register(UINib(nibName: PinInFeedCell.nibName, bundle: nil), forCellReuseIdentifier: PinInFeedCell.cellId)
        pinsTable.delegate = self
        pinsTable.showsVerticalScrollIndicator = false
        
        //load data
        StorageManager.shared.pins.bind(to: pinsTable.rx.items) { cell, index, pin in
            let cell = cell.dequeueReusableCell(withIdentifier: PinInFeedCell.cellId,for: IndexPath(item: index, section: 0)) as! PinInFeedCell
            cell.uploadData(pin)
            self.pins[index] = pin
            return cell
        }.disposed(by: disposeBag)
        
        //init drop-down list table
        dropDownListTable.register(UINib(nibName: DropDownListCell.nibName, bundle: nil), forCellReuseIdentifier: DropDownListCell.cellId)
        dropDownListTable.tag = 1
        dropDownListTable.delegate = self
        dropDownListTable.dataSource = self
        dropDownListTable.showsVerticalScrollIndicator = false
        dropDownListTable.transform = CGAffineTransform(scaleX: 1, y: 0)
        
        //init drop-down list model
        dropDownListModel = DropDownListModel(list: ["Global","Ukraine","Sumy region","Shostka"], countOfBlocks: 3, delegate: self)!
    }
    
    @IBAction func dropDownListAction(_ sender: Any) {
        dropDownListModel.changeList()
    }
    
    @IBAction func tapToSpaceAction(_ sender: Any) {
        dropDownListModel.changeList(isOpen: false)
    }
    
}

extension FeedController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dropDownListModel.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: DropDownListCell.cellId, for: indexPath) as? DropDownListCell {
            cell.uploadData(text: dropDownListModel.list[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 { //if use pins table
            if dropDownListModel.isOpen {
                dropDownListModel.changeList(isOpen: false)
            } else {
                if let pin = pins[indexPath.row] {
                    let viewModel = ViewReportViewModel(pin: pin)
                    let controller = ViewReportController(viewModel: viewModel)
                    present(controller, animated: true)
                }
            }
        } else { //if use drop-down list table
            dropDownListModel.selectItem(index: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 1 { //if use drop-down list table
            return dropDownListTable.frame.height/dropDownListModel.countOfBlocks
        } else {
            return 100
        }
    }
    
}

extension FeedController: DropDownListDelegate {
    
    func changeList(isOpen: Bool) {
        let duration: TimeInterval = 0.5
        let delay: TimeInterval = 0.2
        if isOpen { //bad animation
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn) {
                self.dropDownListTable.transform = .identity
                self.dropDownListArrowImage.transform = CGAffineTransform(rotationAngle: Double.pi)
            }
        } else {
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut) {
                self.dropDownListTable.transform = CGAffineTransform(scaleX: 1, y: 0)
                self.dropDownListArrowImage.transform = .identity
            }
        }
    }
    
    func setButtonName(_ name: String) {
        let attributedText = NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 25)!])
        dropDownListButton.setAttributedTitle(attributedText, for: .normal)
    }

}
