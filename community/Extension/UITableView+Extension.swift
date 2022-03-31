//
//  UITableView+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 31.03.2022.
//

import UIKit

extension UITableView {
    public func register(_ cellTypes: UITableViewCell.Type...) {
        cellTypes.forEach { register($0.nib, forCellReuseIdentifier: $0.identifier) }
    }
}
