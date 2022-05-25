//
//  MomentsView.swift
//  community
//
//  Created by Illia Kniaziev on 05.04.2022.
//

import UIKit
import RxSwift

class MomentsView: UIView {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topOffsetConstraint: NSLayoutConstraint!
    
    var viewModel: MomentsViewModel?
    private let itemOffset: CGFloat = 5
    private let disposeBag = DisposeBag()

    func configure(withHeight height: CGFloat) {
        collectionView.register(MomentCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: itemOffset, left: itemOffset, bottom: itemOffset, right: itemOffset)
        collectionView.showsHorizontalScrollIndicator = false
        
        let itemHeight = height - itemOffset * 2
        
        viewModel?.momentsObservable
            .bind(to: collectionView.rx.items) { cell, index, pin in
                let cell = cell.dequeueReusableCell(
                    withReuseIdentifier: MomentCollectionViewCell.identifier,
                    for: IndexPath(item: index, section: 0)) as! MomentCollectionViewCell
                cell.configure(withHeight: itemHeight)
                cell.imageView.image = nil
                
                StorageManager.shared.getStorageReference(forPinPreview: pin) { ref in
                    if let ref = ref {
                        StorageManager.shared.fetchData(forRef: ref) { result in
                            if case .success(let data) = result {
                                DispatchQueue.main.async { [weak cell] in
                                    cell?.imageView.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
                
                return cell
            }
            .disposed(by: disposeBag)
    }

}

extension MomentsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = collectionView.frame.height - itemOffset * 2
        return CGSize(width: length, height: length)
    }
}
