//
//  ViewController.swift
//  community
//
//  Created by Illia Kniaziev on 18.02.2022.
//

import UIKit
import GoogleSignIn

class AuthViewController: ViewController {

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
        view.backgroundColor = .systemIndigo
        prepareGoogleButton()
        navigationController?.navigationBar.isHidden = true
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        _ = viewModel.transform(AuthViewModel.Input())
    }
    
    private func prepareGoogleButton() {
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10)
        ])
        button.addTarget(self, action: #selector(requestSignIn), for: .touchUpInside)
    }

    @objc private func requestSignIn() {
        GoogleAuthManager.shared.signIn()
    }

}

