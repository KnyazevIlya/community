//
//  UICollectionView+Extension.swift
//  community
//
//  Created by Illia Kniaziev on 09.03.2022.
//

import UIKit

extension UICollectionView {
    public func register(_ cellTypes: UICollectionViewCell.Type...) {
        cellTypes.forEach { register($0.nib, forCellWithReuseIdentifier: $0.identifier) }
    }
}
