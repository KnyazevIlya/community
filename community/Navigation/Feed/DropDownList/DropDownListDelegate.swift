//
//  DropDownListDelegate.swift
//  community
//
//  Created by Anatoliy Khramchenko on 30.05.2022.
//

import UIKit

protocol DropDownListDelegate: AnyObject {
    func changeList(isOpen: Bool)
    func setButtonName(_ name: String)
}
