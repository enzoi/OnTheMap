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
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var results: StudentInformation?
    var website: String = ""
    var annotation = MKPointAnnotation()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activity Indicator Setup
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        self.latitude = (self.results?.latitude)!
        self.longitude = (self.results?.longitude)!
        
        // span to zoom(code below created based on the solution from https://stackoverflow.com/questions/39615416/swift-span-zoom)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude), span: span)
        self.mapView.setRegion(region, animated: true)
        
        let pinLocation = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        self.annotation.coordinate = pinLocation
        self.annotation.title = (self.results?.firstName)! + " " + (self.results?.lastName)!
        self.annotation.subtitle = self.results?.mediaURL
        
        self.mapView.addAnnotation(annotation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func finishButtonPressed(_ sender: Any) {
        
        self.activityIndicator.startAnimating()

        if let objectId = self.results?.objectId { // Update data with new information
            
            // PUT data
            UdacityClient.sharedInstance().putStudentInformation(self, object_id: objectId, dict: self.results!) { (success, error) in
                performUIUpdatesOnMain {
                    if (success != nil) {
                        
                        self.activityIndicator.stopAnimating()
                        // go back to location map view
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    } else {
                        
                        self.getAlertView(title: "Failed to Post Student Information", error: error! as! String)
                        
                    }
                }
            }
        
        } else {
            
            // POST data
            UdacityClient.sharedInstance().postStudentInformation(self, dict: self.results!) { (success, error) in
                
                performUIUpdatesOnMain {
                    if (success != nil) {
                        
                        self.activityIndicator.stopAnimating()
                        // go back to location map view
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    } else {
                        
                        self.getAlertView(title: "Failed to Overwrite Student Information", error: error! as! String)
                        
                    }
                }
            }
            
        }
    }

}
