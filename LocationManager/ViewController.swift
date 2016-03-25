//
//  ViewController.swift
//  LocationManager
//
//  Created by Nam (Nick) N. HUYNH on 3/24/16.
//  Copyright (c) 2016 Enclave. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    
    func displayAlertWithTitle(title: String, message: String) {
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        controller.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func createLocationManager(#startImmediately: Bool) {
        
        locationManager = CLLocationManager()
        if let manager = locationManager {
            
            println("Succeed")
            manager.delegate = self
            if startImmediately {
                
                manager.startUpdatingLocation()
                
            }
            
        }
        
    }
    
    func addPinToMapView() {
        
        let redLocation = CLLocationCoordinate2D(latitude: 58.592737, longitude: 16.185898)
        let blueLocation = CLLocationCoordinate2D(latitude: 58.593038, longitude: 16.188129)
        let redAnnotation = MyAnnotation(coordinate: redLocation, title: "Red", subTitle: "Enclave 1", pinColor: PinColor.Red)
        let blueAnnotation = MyAnnotation(coordinate: blueLocation, title: "Blue", subTitle: "Enclave 2")
        mapView.addAnnotations([redAnnotation, blueAnnotation])
        setCenterOfMapToLocation(blueLocation)
        
    }
    
    func setCenterOfMapToLocation(location:CLLocationCoordinate2D) {
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func showUserLocationOnMapView() {
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.Follow
        
    }
    
    func provideDirection() {
        
        let destination = "Apple Inc."
        CLGeocoder().geocodeAddressString(destination, completionHandler: { (placemarks, error) -> Void in
            
            if error != nil {
                
                
                
            } else {
                
                let request = MKDirectionsRequest()
                request.setSource(MKMapItem.mapItemForCurrentLocation())
                
                let placemark = placemarks[0] as CLPlacemark
                let destinationCoordinates = placemark.location.coordinate
                let destination = MKPlacemark(coordinate: destinationCoordinates, addressDictionary: nil)
                request.setDestination(MKMapItem(placemark: destination))
                request.transportType = MKDirectionsTransportType.Automobile
                
                let directions = MKDirections(request: request)
                directions.calculateDirectionsWithCompletionHandler({ (response, error) -> Void in
                    
                    let launchOptions = [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                    ]
                    
                    MKMapItem.openMapsWithItems([response.source, response.destination], launchOptions: launchOptions)
                    
                })
                
            }
            
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
                
            case CLAuthorizationStatus.Denied:
                println("Denied")
                displayAlertWithTitle("Not Determined", message: "Location services are not allowed for this app")
            case CLAuthorizationStatus.NotDetermined:
                println("NotDetermined")
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager {
                    
                   manager.requestAlwaysAuthorization()
                    
                }
            case CLAuthorizationStatus.Restricted:
                println("Restricted")
                displayAlertWithTitle("Restricted", message: "Location services has been restricted")
            default:
                showUserLocationOnMapView()
//                provideDirection()
                
            }
            
        } else {
            
            println("Location services are not enabled")
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println("Error: \(error)")
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        
        println("Lat: \(newLocation.coordinate.latitude)")
        println("Long: \(newLocation.coordinate.longitude)")
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        if annotation is MyAnnotation == false {
            
            return nil
            
        }
        
        let senderAnnotation = annotation as MyAnnotation
        let pinResuableIdentifier = senderAnnotation.pinColor.rawValue
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinResuableIdentifier) as? MKPinAnnotationView
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: senderAnnotation, reuseIdentifier: pinResuableIdentifier)
            annotationView?.canShowCallout = true
            
        }
        
        annotationView?.pinColor = senderAnnotation.pinColor.toPinColor()
        
        return annotationView
        
    }
    
    func mapView(mapView: MKMapView!, didFailToLocateUserWithError error: NSError!) {
        
        displayAlertWithTitle("Failed", message: "Could not get user's location!")
        
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "restaurants"
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: userLocation.location.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) -> Void in
            
            for item in response.mapItems as [MKMapItem] {
                
                println("Item name = \(item.name)")
                println("Item phone number = \(item.phoneNumber)")
                println("Item url = \(item.url)")
                println("Item location = \(item.placemark.location)")
                
            }
            
        }
        
        let eyeCoordinate = CLLocationCoordinate2D(latitude: 58.571647, longitude: 16.234660)
        let camera = MKMapCamera(lookingAtCenterCoordinate: userLocation.coordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 400.0)
        mapView.setCamera(camera, animated: true)
        
    }
    
}

