//
//  ViewController.swift
//  community
//
//  Created by Illia Kniaziev on 18.02.2022.
//

import UIKit
import GoogleSignIn

class AuthController: ViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    
    private let viewModel: AuthViewModel
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let button: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        contentView.layer.cornerRadius = 20
        
        prepareGoogleButton()
        animateLogInAppearence()
    }
    
    private func prepareGoogleButton() {
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10)
        ])
        button.addTarget(self, action: #selector(requestSignIn), for: .touchUpInside)
    }
    
    private func animateLogInAppearence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.contentViewBottomOffset.constant = self.contentViewHeightConstraint.constant
            UIView.animate(withDuration: 1) {
                self.view.layoutSubviews()
            }
        }
    }

    @objc private func requestSignIn() {
        GoogleAuthManager.shared.signIn()
    }

}

