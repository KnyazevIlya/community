//
//  AuthViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 21.02.2022.
//

import RxSwift

class AuthViewModel: ViewModel, ViewModelType {
    struct Input {}
    struct Output {}
    
    private let disposeBag = DisposeBag()
    private var router: AuthRouter
    
    init(router: AuthRouter) {
        self.router = router
    }
    
    func transform(_ input: Input) -> Output {
        GoogleAuthManager.shared.state
            .subscribe(onNext: { [weak self] state in
                if state == .signedIn {
                    self?.router.toMainFlow()
                }
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    
}
