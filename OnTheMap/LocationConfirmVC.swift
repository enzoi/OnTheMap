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
    
    var alertController: UIAlertController?
    var results: Dictionary<String, Any> = [:]
    var website: String = ""
    var annotation = MKPointAnnotation()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.latitude = self.results["latitude"] as! Double
        self.longitude = self.results["longitude"] as! Double
        
        // span to zoom(code below created based on the solution from https://stackoverflow.com/questions/39615416/swift-span-zoom)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), span: span)
        self.mapView.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        self.annotation.coordinate = pinLocation
        self.annotation.title = (self.results["firstName"] as! String) + " " + (self.results["lastName"] as! String)
        self.annotation.subtitle = self.results["mediaURL"] as? String
        
        self.mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        if let objectId = self.results["objectId"] { // Update data with new information
            
            self.putStudentInformation(object_id: objectId as! String, dict: self.results)
            
        } else {
            
            // POST data to Parse
            self.postStudentInformation(dict: self.results)
            
        }
        
        // go back to location map view
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    private func postStudentInformation(dict: [String: Any]) {
            
        // UdacityClient
        
    }
    
    private func putStudentInformation(object_id: String, dict: [String : Any]) {


    }

}
