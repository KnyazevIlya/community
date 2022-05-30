//
//  DropDownListCell.swift
//  community
//
//  Created by Anatoliy Khramchenko on 29.05.2022.
//

import UIKit

class DropDownListCell: UITableViewCell {
    
    static let cellId = "dropDownListCell"
    static let nibName = "DropDownListCell"

    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func uploadData(text: String) {
        name.text = text
    }
    
}
