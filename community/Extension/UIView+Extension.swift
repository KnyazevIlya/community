//
//  UIView+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import UIKit

extension UIView {
    
    static var identifier: String {
        return "\(self)"
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
