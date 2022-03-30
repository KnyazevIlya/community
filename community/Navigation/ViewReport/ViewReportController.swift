//
//  ViewReportController.swift
//  community
//
//  Created by Illia Kniaziev on 29.03.2022.
//

import UIKit
import RxSwift

class ViewReportController: ViewController {

    @IBOutlet weak var reportNameLabel: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var reportDescription: UILabel!
    @IBOutlet weak var mediaCollection: UICollectionView!
    
    private let viewModel: ViewReportViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: ViewReportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
    }
    
    override func bindViewModel() {
        reportNameLabel.text = viewModel.pin.name
        reportDescription.text = viewModel.pin.description
        
        viewModel.locationObservable
            .subscribe(onNext: { [weak self] text in
                self?.animateTextAppearence(withText: text, forLabel: self?.locationName)
            })
            .disposed(by: disposeBag)
        
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
    }
    
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
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ViewReportController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
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
