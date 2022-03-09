//
//  MediaCell.swift
//  community
//
//  Created by Illia Kniaziev on 08.03.2022.
//

import UIKit

class MediaCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.contentMode = .scaleToFill
    }
}
