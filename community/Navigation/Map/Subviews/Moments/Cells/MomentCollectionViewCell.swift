//
//  MomentCollectionViewCell.swift
//  community
//
//  Created by Illia Kniaziev on 05.04.2022.
//

import UIKit

class MomentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    func configure(withHeight height: CGFloat) {
        imageView.backgroundColor = .systemBlue
        imageView.layer.cornerRadius = height / 2
    }

}
