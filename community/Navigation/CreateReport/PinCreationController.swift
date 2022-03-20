//
//  PinCreationController.swift
//  community
//
//  Created by Illia Kniaziev on 04.03.2022.
//

import UIKit
import CoreLocation
import RxSwift
import DropDown
import FirebaseFirestore

class PinCreationController: ViewController {

    //MARK: - outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var mediaCollection: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    
    //MARK: - properties
    private let viewModel: PinCreationViewModel
//    private let dropDown = DropDown()
    private let disposeBag = DisposeBag()
    
    init(viewModel: PinCreationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    
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
        
//        dropDown.anchorView = nameTextField
//        dropDown.dataSource = ["test1", "test2", "test3", "other"]
//        dropDown.selectionAction = { index, item in
//          print("Selected item: \(item) at index: \(index)")
//        }
        
        nameTextField.layer.cornerRadius = 5
        descriptionTextView.layer.cornerRadius = 5
        
        nameTextField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
//                self.dropDown.show()
                UIView.transition(with: self.nameLabel, duration: 0.15, options: .transitionCrossDissolve) {
                    self.nameLabel.textColor = .systemBlue
                }
            })
            .disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
//                self.dropDown.hide()
                UIView.transition(with: self.nameLabel, duration: 0.15, options: .transitionCrossDissolve) {
                    self.nameLabel.textColor = .secondaryGray
                }
            })
            .disposed(by: disposeBag)
        
        nameTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                self?.descriptionTextView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                UIView.transition(with: self.descriptionLabel, duration: 0.15, options: .transitionCrossDissolve) {
                    self.descriptionLabel.textColor = .systemBlue
                }
            })
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                UIView.transition(with: self.descriptionLabel, duration: 0.15, options: .transitionCrossDissolve) {
                    self.descriptionLabel.textColor = .secondaryGray
                }
            })
            .disposed(by: disposeBag)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.rx.event
            .bind { [weak self] event in
                self?.view.endEditing(false)
            }
            .disposed(by: disposeBag)
        view.addGestureRecognizer(tapRecognizer)
        
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
                cell.image = image
                return cell
            case .video(let url):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCell.identifier, for: indexPath) as! VideoCell
                cell.configure(withVideoUrl: url)
                return cell
            }
        }
        .disposed(by: disposeBag)
        
        viewModel.locationObservable
            .subscribe(onNext: { [weak self] text in
                self?.animateLocationTextAppearence(text: text)
            })
            .disposed(by: disposeBag)
        
        mediaCollection.rx.itemSelected.subscribe(onNext: { [weak self] index in
                if index.item == 0 {
                    self?.showPickerAlert(completion: { source in
                        self?.presentImagePicker(source: source)
                    })
                }
            })
            .disposed(by: disposeBag)
        
        nameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.nameRelay)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text
            .orEmpty
            .bind(to: viewModel.descriptionRelay)
            .disposed(by: disposeBag)
        
        let input = PinCreationViewModel.Input(
            sendTap: sendButton.rx.tap.asDriver()
        )
        
        let output = viewModel.transform(input)
        
        output.sendTapped
            .drive(onNext: { [weak self] in
                if let text = self?.nameTextField.text, !text.isEmpty {
                    self?.dismiss(animated: true)
                } else {
                    self?.alertEmptyName()
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - private
    private func configureCollectionView() {
        mediaCollection.register(
            AddMediaCell.self,
            MediaCell.self,
            VideoCell.self
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
            imagePicker.mediaTypes = ["public.image", "public.movie"]
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
    
    private func animateLocationTextAppearence(text: String?) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        locationLabel.text = text
        animation.duration = 0.25
        locationLabel.layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    private func alertEmptyName() {
        nameTextField.layer.borderWidth = 3
        nameTextField.layer.borderColor = UIColor.red.cgColor
        
        UIView.transition(with: nameLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.nameLabel.textColor = .red
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension PinCreationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.acceptNewMedia(.photo(image))
        } else if let url = info[.mediaURL] as? URL {
            viewModel.acceptNewMedia(.video(url))
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension PinCreationController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - 10
        let width = height * (3 / 4)
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let verticalIndicatorView = (scrollView.subviews[(scrollView.subviews.count - 1)].subviews[0])
        verticalIndicatorView.backgroundColor = .systemBlue.withAlphaComponent(0.8)
    }
}
