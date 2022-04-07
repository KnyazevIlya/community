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
    
    private let itemOffset: CGFloat = 5

    func configure(withHeight height: CGFloat) {
        collectionView.register(MomentCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: itemOffset, left: itemOffset, bottom: itemOffset, right: itemOffset)
        collectionView.showsHorizontalScrollIndicator = false
        
        let o = Observable<String>.of("ssssaflefwmkl")
        let itemHeight = height - itemOffset * 2
        
        o.bind(to: collectionView.rx.items) { c, i, e in
            let cell = c.dequeueReusableCell(withReuseIdentifier: MomentCollectionViewCell.identifier, for: IndexPath(item: i, section: 0)) as! MomentCollectionViewCell
            cell.configure(withHeight: itemHeight)
            return cell
        }
    }

}

extension MomentsView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = collectionView.frame.height - itemOffset * 2
        return CGSize(width: length, height: length)
    }
}
