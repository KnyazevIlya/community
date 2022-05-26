//
//  PinInFeedCell.swift
//  community
//
//  Created by Anatoliy Khramchenko on 26.05.2022.
//

import UIKit

class PinInFeedCell: UITableViewCell {
    
    static let cellId = "pinInFeedCell"
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinNameLabel: UILabel!
    @IBOutlet weak var pinDescriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func uploadData(_ data: Pin) {
        pinNameLabel.text = data.name
        pinDescriptionLabel.text = data.description
        pinImage.image = UIImage(named: "none")
        
        //load photo
        DispatchQueue.global(qos: .userInitiated).async {
            StorageManager.shared.getStorageReference(forPinPreview: data) { ref in
                if let ref = ref {
                    StorageManager.shared.fetchData(forRef: ref) { result in
                        if case .success(let gettedData) = result {
                            DispatchQueue.main.async { 
                                self.pinImage.image = UIImage(data: gettedData)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
