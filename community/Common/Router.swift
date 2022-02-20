//
//  Router.swift
//  community
//
//  Created by Illia Kniaziev on 20.02.2022.
//

import UIKit

protocol Router {
    var navigationController: UINavigationController? { get }
    init(navigationController: UINavigationController?)
    func toSelf()
}
