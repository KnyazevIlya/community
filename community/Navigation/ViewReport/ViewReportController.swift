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
    
    override func bindViewModel() {
        reportNameLabel.text = viewModel.pin.name
        reportDescription.text = viewModel.pin.description
        
        viewModel.locationObservable
            .subscribe(onNext: { [weak self] text in
                self?.animateTextAppearence(withText: text, forLabel: self?.locationName)
            })
            .disposed(by: disposeBag)
    }
    
}
