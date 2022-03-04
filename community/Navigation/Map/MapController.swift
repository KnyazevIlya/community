//
//  MapController.swift
//  community
//
//  Created by Illia Kniaziev on 22.02.2022.
//

import UIKit
import MapKit
import RxSwift

class MapController: ViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let disposeBag = DisposeBag()
    private let viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGesture()
        mapView.delegate = self
    }
    
    private func configureGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: nil)
        mapView.addGestureRecognizer(longPressGesture)
        
        longPressGesture
            .rx.event.bind(onNext: { [weak self] gestureRecognizer in
                guard let self = self else { return }
                
                if gestureRecognizer.state == .began {
                    let touchLocation = gestureRecognizer.location(in: self.mapView)
                    let coords = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
                    
                    self.removeAnnotations(type: CreationAnnotation.self)
                    
                    let pin = CreationAnnotation(
                        title: "Add",
                        coordinate: coords
                    )
                    self.mapView.addAnnotation(pin)
                    self.mapView.setCenter(coords, animated: true)
                    
                    FeedbackManager.shared.giveSuccessFeedback()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func prepareMapView() {
        mapView.register(CreationAnnotation.self, forAnnotationViewWithReuseIdentifier: CreationAnnotation.reuseIdentifier)
    }
    
    private func removeAnnotations<T>(type: T.Type) {
        mapView.annotations.lazy.forEach {
            if $0 is T {
                self.mapView.removeAnnotation($0)
            }
        }
    }
      
}

extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        var annotationView: MKMarkerAnnotationView? = nil
        
        if let annotation = annotation as? CreationAnnotation {
            if let creation = mapView.dequeueReusableAnnotationView(withIdentifier: CreationAnnotation.reuseIdentifier) as? MKMarkerAnnotationView {
                creation.annotation = annotation
                annotationView = creation
            } else {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: CreationAnnotation.reuseIdentifier)
            }
            
            annotationView?.tintColor = .systemBlue
            annotationView?.glyphImage = UIImage(systemName: "plus")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            annotationView?.titleVisibility = .hidden
        }
        
        return annotationView
    }
}
