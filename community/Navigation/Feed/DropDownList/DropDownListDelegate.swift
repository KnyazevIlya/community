//
//  DropDownListDelegate.swift
//  community
//
//  Created by Anatoliy Khramchenko on 30.05.2022.
//

import UIKit

protocol DropDownListDelegate {
    func changeList(isOpen: Bool)
    func setButtonName(_ name: String)
}
