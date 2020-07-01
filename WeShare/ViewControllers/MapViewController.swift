//
//  MapViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 27/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, DatabaseListener, CLLocationManagerDelegate, MKMapViewDelegate {
    var listenerType: ListenerType = .listings
    var locationManager: CLLocationManager = CLLocationManager()
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var mapView: MKMapView!
    
    private var allAnnotations: [MKAnnotation] = []
    
    private var displayedAnnotations: [MKAnnotation]? {
        willSet {
            if let currentAnnotations = displayedAnnotations {
                mapView.removeAnnotations(currentAnnotations)
            }
        }
        didSet {
            if let newAnnotations = displayedAnnotations {
                mapView.addAnnotations(newAnnotations)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // register class with identifier
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(MapAnnotation.self))
    }

    
    func onListingsChange(change: DatabaseChange, listings: [Listing]) {
        print(listings.count)
        
        // Remove existing annotations before adding new ones
        mapView.removeAnnotations(allAnnotations)
        
        listings.forEach { listing in
            print(listing.desc!)
            let annotation = MapAnnotation(title: listing.title!, subtitle: listing.desc!, lat: listing.location![0], lng: listing.location![1], iconName: (listing.category?.systemIcon!)!, listing: listing)
            
            
            mapView.addAnnotation(annotation)
            allAnnotations.append(annotation)
        }
    }
    
    func onActivitiesChange(change: DatabaseChange, activities: [Activity]) {}
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? MapAnnotation else {
            return nil
        }
        
        let identifier = NSStringFromClass(MapAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            
            markerAnnotationView.glyphImage = UIImage(systemName: annotation.systemIconName!)

            
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.markerTintColor = UIColor.givingColor(giving: (annotation.listing!.giving)!)
            
            markerAnnotationView.loadDescription(description: annotation.subtitle!)
            
            let rightButton = UIButton(type: .detailDisclosure)
            markerAnnotationView.rightCalloutAccessoryView = rightButton
        }
        
        return view
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "listingDetailSegue" {
            let destination = segue.destination as! ListingDetailViewController
            destination.listing = sender as? Listing
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        databaseController?.addListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        databaseController?.removeListener(listener: self)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
    }

    // Called when user tap on right detail button
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapAnnotation {
            
            performSegue(withIdentifier: "listingDetailSegue", sender: annotation.listing)
        }
    }
    
}

extension MKAnnotationView {

    func loadDescription(description: String) {
        
        let customLines = description.components(separatedBy: CharacterSet.newlines)
        
        let stackView = self.stackView()
        for line in customLines {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.preferredMaxLayoutWidth = 30
            label.text = line
            stackView.addArrangedSubview(label)
        }
        self.detailCalloutAccessoryView = stackView
    }



    private func stackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }
}

// Locations
// Monash University Clayton        [-37.910549, 145.136218]
// 16 Koonawarra                    [-37.907716, 145.125412]
// 71 Madeleine Road                [-37.920170, 145.118847]
