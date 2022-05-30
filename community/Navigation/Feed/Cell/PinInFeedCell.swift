//
//  PinInFeedCell.swift
//  community
//
//  Created by Anatoliy Khramchenko on 26.05.2022.
//

import UIKit
import RxCocoa
import CoreLocation
import RxSwift

class PinInFeedCell: UITableViewCell {
    
    static let cellId = "pinInFeedCell"
    static let nibName = "PinInFeedCell"
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
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
        
        //load location
        locationLabel.text = "Loading..."
        let coordinates = CLLocationCoordinate2D(firestoreCoordinates: data.coordinates)
        LocationManager.shared.geocode(coordinates: coordinates) { name in
            DispatchQueue.main.async {
                if let name = name {
                    self.locationLabel.text = "📍 \(name)"
                }
            }
        }
        //fix reloading
    }
    
}
