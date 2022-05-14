//
//  MomentsViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 05.04.2022.
//

import RxRelay

class MomentsViewModel {
    
    let momentsObservable = PublishRelay<[Pin]>()
}
