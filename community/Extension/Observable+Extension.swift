//
//  Observable+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import RxSwift
import RxCocoa

extension ObservableType {
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
