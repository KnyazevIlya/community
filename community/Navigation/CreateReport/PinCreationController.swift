//
//  PinCreationController.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import UIKit
import CoreLocation
import RxSwift

class PinCreationController: ViewController {

    //MARK: - outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mediaCollection: UICollectionView!
    
    //MARK: - properties
    var coordinates: CLLocationCoordinate2D!
    private let viewModel: PinCreationViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: PinCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            LocationManager.shared.geocode(coordinates: self.coordinates) {
                self.locationLabel.text = $0
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    
    override func customizeInterface() {
        super.customizeInterface()
        
        nameTextField.layer.cornerRadius = 5
        descriptionTextView.layer.cornerRadius = 5
        
        configureCollectionView()
    }
    
    //MARK: - public
    override func bindViewModel() {
        super.bindViewModel()
        
        viewModel.mediaObservable.bind(to: mediaCollection.rx.items) { collectionView, index, element in
            let indexPath = IndexPath(item: index, section: 0)

            switch element {
            case .add:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMediaCell.identifier, for: indexPath) as! AddMediaCell
                return cell
            case .photo(let image):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaCell.identifier, for: indexPath) as! MediaCell
                cell.imageView.image = image
                return cell
            case .video:
                fatalError("Video cell is not implemented yet")
            }
        }
        .disposed(by: disposeBag)
    }
    
    //MARK: - private
    private func configureCollectionView() {
        mediaCollection.register(
            AddMediaCell.self,
            MediaCell.self
        )
        
        mediaCollection.delegate = self
        
        mediaCollection.backgroundColor = .secondaryGray.withAlphaComponent(0.2)
        mediaCollection.layer.cornerRadius = 5
        mediaCollection.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        mediaCollection.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 2, bottom: -2, right: 2)
    }
    
    private func presentImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        }
    }
    
    private func showPickerAlert(completion: @escaping (UIImagePickerController.SourceType) -> ()) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Take a photo", style: .default) { _ in
            completion(UIImagePickerController.SourceType.camera)
        })
        ac.addAction(UIAlertAction(title: "Choose from the gallery", style: .default) { _ in
            completion(UIImagePickerController.SourceType.photoLibrary)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}

//MARK: - UIImagePickerControllerDelegate
extension PinCreationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        viewModel.acceptNewMedia(.photo(info[.originalImage] as? UIImage))
        dismiss(animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension PinCreationController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 10
        let width = height * (3 / 4)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showPickerAlert(completion: { [weak self] source in
            self?.presentImagePicker(source: source)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let verticalIndicatorView = (scrollView.subviews[(scrollView.subviews.count - 1)].subviews[0])
        verticalIndicatorView.backgroundColor = .systemBlue.withAlphaComponent(0.8)
    }
}
