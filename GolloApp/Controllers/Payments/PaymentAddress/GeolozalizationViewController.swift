//
//  GeolozalizationViewController.swift
//  GolloApp
//
//  Created by Rodrigo Osegueda on 18/8/23.
//

import UIKit
import MapKit
import CoreLocation

protocol GeolozalizationCoordinateDelegate {
    func addingCoordinates(with coordinateX: Double, coordinateY: Double)
}

class GeolozalizationViewController: UIViewController, MKMapViewDelegate {
    // MARK: - Outlets
    @IBOutlet weak var locationMapView: MKMapView!
    
    // MARK: - Variables
    let manager = CLLocationManager()
    var userCoordinate: CLLocationCoordinate2D? = nil
    let delegate: GeolozalizationCoordinateDelegate
    
    // MARK: - Lifecycle
    init(delegate: GeolozalizationCoordinateDelegate) {
        self.delegate = delegate
        super.init(nibName: "GeolozalizationViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationMapView.delegate = self
        // For getting location while tapping on map we need to add UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        locationMapView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        if let userCoordinate = userCoordinate {
            delegate.addingCoordinates(with: userCoordinate.latitude, coordinateY: userCoordinate.longitude)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest // battery
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    @objc func handleTap(gestureReconizer: UITapGestureRecognizer) {
        let location = gestureReconizer.location(in: locationMapView)
        let coordinate = locationMapView.convert(location,toCoordinateFrom: locationMapView)
        self.userCoordinate = coordinate
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        print(" Coordinates: \(coordinate)")
        print(" Coordinates: \(coordinate.latitude.magnitude) ~~ \(coordinate.longitude.magnitude)")
        
        /* to show only one pin while tapping on map by removing the last.
         If you want to show multiple pins you can remove this piece of code */
        if locationMapView.annotations.count == 1 {
            locationMapView.removeAnnotation(locationMapView.annotations.last!)
        }
        locationMapView.addAnnotation(annotation) // add annotaion pin on the map
    }
    
}

extension GeolozalizationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            manager.stopUpdatingLocation()
            
            render(location)
        }
    }
    
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.userCoordinate = coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        locationMapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        locationMapView.addAnnotation(pin)
    }
}
