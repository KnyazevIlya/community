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
    @IBOutlet weak var queueButton: VisibilityButton!
    
    private var momentsView: MomentsView = {
        let view = Bundle.main.loadNibNamed("MomentsView", owner: nil)?.first as! MomentsView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()
    private var idsOnMap = Set<String>()
    private var annotationsBag = [String : IncidentAnnotation]()
    private var needsInitialMomentsViewUpdate = true
    private weak var momentsViewModel: MomentsViewModel?

    private let spanDelta:           CLLocationDegrees = 0.125
    private let reachabilityRadius: CLLocationDistance = 3000 //3km
    private let reachabilityAreaBorderWidth:   CGFloat = 5
    private let momentsHeight:                 CGFloat = 100
    private var reachabilityOpacity:             Float = 0.3
    
    init(viewModel: MapViewModel) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGesture()
        prepareMapView()
        configureMomentsView()
        configureRegionChangeHandling()
        
        StorageManager.shared.pins
            .subscribe(onNext: { [weak self] pins in
                guard let self = self else { return }
                
                var idBag = Set<String>()
                
                print("🟣 pins count: \(pins.count)")
                for pin in pins {
                    self.addUniquePin(pin: pin, idBag: &idBag)
                }
                
                let uuidsToRemove = self.idsOnMap.subtracting(idBag)
                for uuid in uuidsToRemove {
                    if let annotation = self.annotationsBag[uuid] {
                        self.mapView.removeAnnotation(annotation)
                    }
                    
                    self.annotationsBag[uuid] = nil
                }
                
                self.idsOnMap = idBag
                
                if self.needsInitialMomentsViewUpdate {
                    self.needsInitialMomentsViewUpdate.toggle()
                    self.updateMomentsView()
                }
            })
            .disposed(by: disposeBag)
        
        LocationManager.shared.currentLocation
            .take(1)
            .subscribe(onNext: { [weak self] location in
                if let location = location {
                    self?.zoomToCurrentLocation(location)
                }
            })
            .disposed(by: disposeBag)
                
        LocationManager.shared.currentLocation
            .subscribe(onNext: { [weak self] location in
                if let self = self, let coordinate = location?.coordinate {
                    self.updateCircleOverlay(center: coordinate, radius: self.reachabilityRadius)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        viewModel.sendTrigger
            .subscribe(onNext: { [weak self] in
                self?.removeAnnotations(type: CreationAnnotation.self)
            })
            .disposed(by: disposeBag)
        
        let input = MapViewModel.Input(queueTap: queueButton.rx.tap.asDriver())
        let output = viewModel.transform(input)
        output.queueTapped.drive().disposed(by: disposeBag)
    }
    
    //MARK: - visibility btn
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
    
    //MARK: - moments views
    private func configureMomentsView() {
        let topOffset = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController?.view
            .safeAreaInsets.top ?? 0
        
        momentsView.topOffsetConstraint.constant = topOffset
        
        view.addSubview(momentsView)
        NSLayoutConstraint.activate([
            momentsView.leftAnchor.constraint(equalTo: view.leftAnchor),
            momentsView.topAnchor.constraint(equalTo: view.topAnchor),
            momentsView.rightAnchor.constraint(equalTo: view.rightAnchor),
            momentsView.heightAnchor.constraint(equalToConstant: momentsHeight + topOffset)
        ])
        
        let momentsViewModel = MomentsViewModel()
        momentsView.viewModel = momentsViewModel
        momentsView.configure(withHeight: momentsHeight)
        
        self.momentsViewModel = momentsViewModel
    }
    
    private func updateMomentsView() {
        let mapRect = mapView.visibleMapRect
        let pins = mapView.annotations(in: mapRect)
            .compactMap { ($0 as? IncidentAnnotation)?.pin }
            .sorted { lhsPin, rhsPin in
                guard let lhs = lhsPin.timestamp?.dateValue(),
                      let rhs = rhsPin.timestamp?.dateValue() else { return false }
                
                return lhs < rhs
            }
        
        momentsViewModel?.momentsObservable.accept(pins)
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
                        
                        let pin = CreationAnnotation(coordinate: coords)
                        self.mapView.addAnnotation(pin)
                        self.mapView.setCenter(coords, animated: true)
                        
                        FeedbackManager().giveSuccessFeedback()
                    } else {
                        //set center to avoid bug, link: https://developer.apple.com/forums/thread/126473
                        self.mapView.setCenter(self.mapView.centerCoordinate, animated: false)
                        FeedbackManager().giveErrorFeedback()
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
    
    private func addUniquePin(pin: Pin, idBag: inout Set<String>) {
        idBag.insert(pin.id)
        
        if annotationsBag[pin.id] != nil { return }
        
        let newAnnotation = IncidentAnnotation(pin: pin)
        mapView.addAnnotation(newAnnotation)
        annotationsBag[pin.id] = newAnnotation
    }
      
    private func configureRegionChangeHandling() {
        let gustureRecognizer = UIPanGestureRecognizer()
        gustureRecognizer.delegate = self
        mapView.addGestureRecognizer(gustureRecognizer)
        
        gustureRecognizer
            .rx.event.bind(onNext: { [weak self] gestureRecognizer in
                if gestureRecognizer.state == .ended {
                    self?.updateMomentsView()
                }
            })
            .disposed(by: disposeBag)
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
            
            annotationView?.markerTintColor = .systemBlue
            annotationView?.glyphImage = UIImage(systemName: "plus")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .contactAdd)
            annotationView?.titleVisibility = .hidden
        } else if let annotation = annotation as? IncidentAnnotation {
            if let incident = mapView.dequeueReusableAnnotationView(withIdentifier: IncidentAnnotation.reuseIdentifier) as? MKMarkerAnnotationView {
                incident.annotation = annotation
                annotationView = incident
            } else {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: IncidentAnnotation.reuseIdentifier)
            }
            
            annotationView?.glyphTintColor = .white
            annotationView?.glyphImage = UIImage(systemName: "exclamationmark.triangle")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .infoDark)
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
            viewModel.pinCreationTrigger.on(.next(coordinate))
        } else if let annotation = view.annotation as? IncidentAnnotation {
            viewModel.pinViewTrigger.on(.next(annotation.pin))
        }
    }
}

extension MapController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
