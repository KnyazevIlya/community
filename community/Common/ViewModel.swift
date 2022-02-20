//
//  ViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 20.02.2022.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input) -> Output
}

class ViewModel {
    deinit {
        print("🟢 \(#function) \(self)")
    }
}
