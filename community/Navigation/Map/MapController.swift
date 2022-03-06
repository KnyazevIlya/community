//
//  MapController.swift
//  community
//
//  Created by Illia Kniaziev on 22.02.2022.
//

import UIKit
import MapKit
import RxSwift
import Popover

class MapController: ViewController {

    //MARK: - properties
    @IBOutlet weak var mapView: MKMapView!
    
    private let disposeBag = DisposeBag()
    private let viewModel: MapViewModel
    
    private let spanDelta: CLLocationDegrees = 0.025
    private let reachabilityRadius: CLLocationDistance = 2000
    private let reachabilityAreaBorderWidth: CGFloat = 5
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGesture()
        prepareMapView()
        
        LocationManager.shared.currentLocation
            .take(1)
            .do(onNext: { [weak self] location in
                if let location = location {
                    self?.zoomToCurrentLocation(location)
                }
            })
            .asDriver(onErrorJustReturn: nil)
            .drive()
            .disposed(by: disposeBag)
                
        LocationManager.shared.currentLocation
            .subscribe(onNext: { [weak self] location in
                if let self = self, let coordinate = location?.coordinate {
                    self.updateCircleOverlay(center: coordinate, radius: self.reachabilityRadius)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func didTapVisibility(_ sender: UIButton) {
        let popoverOrigin = CGPoint(x: sender.frame.midX, y: sender.frame.maxY)
        let viewOrigin = CGPoint(x: 32, y: sender.frame.maxY - 32)
        let viewSize = CGSize(width: 250, height: 100)
        let popoverView = UIView(frame: CGRect(origin: viewOrigin, size: viewSize))
        
        let popover = Popover()
        popover.show(popoverView, point: popoverOrigin)
    }
    
    //MARK: - gestures
    private func configureGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: nil)
        mapView.addGestureRecognizer(longPressGesture)
        
        longPressGesture
            .rx.event.bind(onNext: { [weak self] gestureRecognizer in
                guard let self = self else { return }
                
                if gestureRecognizer.state == .began {
                    let touchLocation = gestureRecognizer.location(in: self.mapView)
                    let coords = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
                    
                    //check if the user leaves a mark in the valid area
                    let touchLocationOnMap = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
                    let distanceToTouchLocation = self.mapView.userLocation.location?.distance(from: touchLocationOnMap) ?? .infinity
                    if distanceToTouchLocation <= self.reachabilityRadius {
                        self.removeAnnotations(type: CreationAnnotation.self)
                        
                        let pin = CreationAnnotation(
                            coordinate: coords
                        )
                        self.mapView.addAnnotation(pin)
                        self.mapView.setCenter(coords, animated: true)
                        
                        FeedbackManager.shared.giveSuccessFeedback()
                    } else {
                        FeedbackManager.shared.giveErrorFeedback()
                    }                    
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - map
    private func prepareMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .hybrid
    }
    
    private func removeAnnotations<T>(type: T.Type) {
        mapView.annotations.lazy.forEach {
            if $0 is T {
                self.mapView.removeAnnotation($0)
            }
        }
    }
    
    private func removeOverlays<T>(type: T.Type) {
        mapView.overlays.lazy.forEach {
            if $0 is T {
                self.mapView.removeOverlay($0)
            }
        }
    }
    
    private func zoomToCurrentLocation(_ location: CLLocation) {
        let span = MKCoordinateSpan(latitudeDelta: spanDelta, longitudeDelta: spanDelta)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func updateCircleOverlay(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        removeOverlays(type: MKCircle.self)
        let circle = MKCircle(center: center, radius: radius)
        mapView.addOverlay(circle)
    }
      
}

//MARK: - MKMapViewDelegate
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circle = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: circle)
            circleRenderer.fillColor = .reachabilityFillColor
            circleRenderer.strokeColor = .reachabilityStrokeColor
            circleRenderer.lineWidth = reachabilityAreaBorderWidth
            
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }
}
