//
//  ViewController.swift
//  community
//
//  Created by Illia Kniaziev on 18.02.2022.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {

    let button: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10)
        ])
    }


}

