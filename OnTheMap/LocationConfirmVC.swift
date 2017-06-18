//
//  LocationConfirmVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/14/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit

class LocationConfirmVC: UIViewController {

    var website: String = ""
    var annotation = MKPointAnnotation()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        
        // set sapn, region, and pin location
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), span: span)
        self.mapView.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        self.annotation.coordinate = pinLocation
        // annotation.title = name
        // annotation.subtitle = self.websiteTextField.text
        
        self.mapView.addAnnotation(annotation)
    }


    @IBAction func finishButtonPressed(_ sender: Any) {
        // Create Student Information instant)
        let dictionary = [String: Any]()
        let objectID: String = UUID().uuidString
        let uniqueKey: String = "12345678910"
        let firstName: String = ""
        let lastName: String = ""
        let latitude: Double = self.latitude
        let longitude: Double = self.longitude
        let mediaURL: String = self.website
//        let createdAt: String  ex) "createdAt":"2017-06-15T06:44:24.225Z"
//        let updatedAt: String  ex) "updatedAt":"2017-06-15T06:44:24.225Z"
        
        // Post data with the new location using Udacity API
        

        
        
        // go back to location map view
        self.navigationController?.popToRootViewController(animated: true)
    }
}
