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
import Lottie

class MapController: ViewController {

    //MARK: - properties
    @IBOutlet weak var mapView: MKMapView!
    
    private let disposeBag = DisposeBag()
    private let viewModel: MapViewModel
    
    private let spanDelta: CLLocationDegrees = 0.125
    private let reachabilityRadius: CLLocationDistance = 3000 //3km
    private let reachabilityAreaBorderWidth: CGFloat = 5
    private var reachabilityOpacity: Float = 0.3
    
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
    
    @IBAction func didTapVisibility(_ sender: VisibilityButton) {
        zoomToCurrentLocation(CLLocation(
            latitude: mapView.userLocation.coordinate.latitude,
            longitude: mapView.userLocation.coordinate.longitude)
        )
        
        let popoverOrigin = CGPoint(x: sender.frame.minX - 2, y: sender.frame.midY)
        let viewOrigin = CGPoint(x: 32, y: sender.frame.maxY - 32)
        let viewSize = CGSize(width: 150, height: 50)
        let popoverView = UIView(frame: CGRect(origin: viewOrigin, size: viewSize))
        
        let slider = UISlider()
        slider.value = reachabilityOpacity * 2
        slider.translatesAutoresizingMaskIntoConstraints = false
        popoverView.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: popoverView.topAnchor, constant: 10),
            slider.bottomAnchor.constraint(equalTo: popoverView.bottomAnchor, constant: -10),
            slider.leftAnchor.constraint(equalTo: popoverView.leftAnchor, constant: 10),
            slider.rightAnchor.constraint(equalTo: popoverView.rightAnchor, constant: -15)
        ])

        let sliderSubscription = slider.rx.value.subscribe(
            onNext: { [weak self] value in
                guard let self = self else { return }
                
                sender.isIconCrossed = value == 0.0
                self.reachabilityOpacity = value / 2
            },
            onDisposed: {
                print("🟢 slider disposed")
            }
        )
        
        let popover = Popover()
        popover.didDismissHandler = {
            sliderSubscription.dispose()
        }
        
        popover.popoverType = .left
        popover.arrowSize = CGSize(width: 10, height: 5)
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
                    let touchLocationOnMap = CLLocation(coordinates: coords)
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
                        //set center to avoid bug, link: https://developer.apple.com/forums/thread/126473
                        self.mapView.setCenter(self.mapView.centerCoordinate, animated: false)
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
        mapView.pointOfInterestFilter = .excludingAll
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
            circleRenderer.fillColor = .systemBlue.withAlphaComponent(CGFloat(reachabilityOpacity))
            circleRenderer.strokeColor = .reachabilityStrokeColor
            circleRenderer.lineWidth = reachabilityAreaBorderWidth
            
            return circleRenderer
        }
        
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let userView = mapView.view(for: mapView.userLocation)
        userView?.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view.annotation is CreationAnnotation, let coordinate = view.annotation?.coordinate {
            viewModel.pinTrigger.on(.next(coordinate))
        }
    }
}
