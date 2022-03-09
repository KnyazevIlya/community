//
//  PinCreationViewModel.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import RxSwift
import RxCocoa

class PinCreationViewModel: ViewModel {
    
    enum MediaCollectionType {
        case add
        case photo(UIImage?)
        case video
    }
    
    let mediaObservable = BehaviorRelay<[MediaCollectionType]>(value: [.add])
    
    func acceptNewMedia(_ media: MediaCollectionType) {
        mediaObservable.accept(mediaObservable.value + [media])
    }
    
}
