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
    
    func animateTextAppearence(withText text: String?, forLabel label: UILabel?) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        label?.text = text
        animation.duration = 0.25
        label?.layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
}
