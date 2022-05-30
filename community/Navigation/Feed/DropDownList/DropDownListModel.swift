//
//  DropDownListModel.swift
//  community
//
//  Created by Anatoliy Khramchenko on 30.05.2022.
//

import UIKit

class DropDownListModel {
    
    private(set) var isOpen = false
    let list: [String]
    let countOfBlocks: CGFloat
    private let dropDownListDelegate: DropDownListDelegate
    
    init(list: [String], countOfBlocks: Int = 4, delegate: DropDownListDelegate) {
        self.list = list
        self.countOfBlocks = CGFloat(countOfBlocks)
        dropDownListDelegate = delegate
    }
    
    func changeList(isOpen: Bool) {
        self.isOpen = isOpen
        dropDownListDelegate.changeList(isOpen: isOpen)
    }
    
    func changeList() {
        isOpen.toggle()
        dropDownListDelegate.changeList(isOpen: isOpen)
    }
    
    func selectItem(index: Int) {
        changeList(isOpen: false)
        dropDownListDelegate.setButtonName(list[index])
    }
    
}