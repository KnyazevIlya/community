//
//  ViewController.swift
//  community
//
//  Created by Illia Kniaziev on 20.02.2022.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeInterface()
        bindViewModel()
    }
    
    func customizeInterface() {}
    
    func bindViewModel() {}
    
    deinit {
        print("🟢 \(#function) \(self)")
    }
}
