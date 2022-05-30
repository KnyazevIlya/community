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
    
    @IBOutlet weak var reactionCollection: UICollectionView!
    private var reactions = [Reaction]()
    
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
    
    func uploadData(_ data: Pin, reactions: [Reaction]) {
        self.reactions = reactions
        reactionCollection.register(UINib(nibName: ReactionCell.nibName, bundle: nil), forCellWithReuseIdentifier: ReactionCell.cellId)
        reactionCollection.delegate = self
        reactionCollection.dataSource = self
        reactionCollection.showsHorizontalScrollIndicator = false
        
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

extension PinInFeedCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReactionCell.cellId, for: indexPath) as? ReactionCell {
            cell.uploadData(reaction: reactions[indexPath.row])
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reactions[indexPath.row].count += 1
        if reactions[indexPath.row].isPressed {
           reactions[indexPath.row].count -= 2
        }
        reactions[indexPath.row].isPressed.toggle()
        reactionCollection.reloadData()
    }
        
}
