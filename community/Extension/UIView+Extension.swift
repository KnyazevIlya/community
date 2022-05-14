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
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    func pin(toView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func center(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
