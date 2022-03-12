//
//  MediaCell.swift
//  community
//
//  Created by Illia Kniaziev on 08.03.2022.
//

import UIKit

class MediaCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!

    var image: UIImage? {
        didSet {
            backgroundImageView.image = image
            imageView.image = image
        }
    }
    
}
