//
//  ReactionCell.swift
//  community
//
//  Created by Anatoliy Khramchenko on 30.05.2022.
//

import UIKit

class ReactionCell: UICollectionViewCell {
    
    static let cellId = "reactionCell"
    static let nibName = "ReactionCell"

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var reactionLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func uploadData(reaction: Reaction) {
        if reaction.isPressed {
            backView.backgroundColor = .systemBlue
        } else {
            backView.backgroundColor = .clear
        }
        backView.layer.borderWidth = 2
        backView.layer.borderColor = UIColor.systemBlue.cgColor
        reactionLabel.text = reaction.reaction
        countLabel.text = String(reaction.count) //reduce
    }

}
