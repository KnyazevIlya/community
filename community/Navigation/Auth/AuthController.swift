//
//  ViewController.swift
//  community
//
//  Created by Illia Kniaziev on 18.02.2022.
//

import UIKit
import GoogleSignIn
import RxSwift

class AuthController: ViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loadingStack: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let viewModel: AuthViewModel
    private let disposeBag = DisposeBag()
    
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
        loadingStack.isHidden = true
        
        prepareGoogleButton()
        animateLogInAppearence()
        
        GoogleAuthManager.shared.state
            .subscribe(onNext: { [weak self] event in
                if event == .inProgress {
                    self?.toggleLoading(isShown: true)
                } else {
                    self?.toggleLoading(isShown: false)
                }
            })
            .disposed(by: disposeBag)
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
    
    private func toggleLoading(isShown: Bool) {
        loadingStack.isHidden = !isShown
        if isShown {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    @objc private func requestSignIn() {
        GoogleAuthManager.shared.signIn()
    }

}

