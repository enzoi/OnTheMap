//
//  LocationMapVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit
import FacebookCore
import FacebookLogin

class LocationMapVC: UIViewController, MKMapViewDelegate {

    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var results: [String: Any]?
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Activity Indicator Setup
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.activityIndicator.startAnimating()
        
        mapView.removeAnnotations(mapView.annotations)
        
        UdacityClient.sharedInstance().getStudentInformations(self) { (studentInformations, error) in
            
            self.mapView.delegate = self
            
            if let error = error {
                print(error)
                
            } else {
                
                if let studentInformations = studentInformations {
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        // We will create an MKPointAnnotation for each dictionary in "locations". The
                        // point annotations will be stored in this array, and then provided to the map view.
                        var annotations = [MKPointAnnotation]()
                        
                        for information in studentInformations {
                            
                            // Notice that the float values are being used to create CLLocationDegree values.
                            // This is a version of the Double type.
                            let lat = CLLocationDegrees(information.latitude)
                            let long = CLLocationDegrees(information.longitude)
                            
                            // The lat and long are used to create a CLLocationCoordinates2D instance.
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            let first = information.firstName
                            let last = information.lastName
                            let mediaURL = information.mediaURL
                            
                            // Here we create the annotation and set its coordiate, title, and subtitle properties
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            annotation.title = "\(first) \(last)"
                            annotation.subtitle = mediaURL
                            
                            // Finally we place the annotation in an array of annotations.
                            annotations.append(annotation)
                        }
                        
                        DispatchQueue.main.async {
                            // When the array is complete, we add the annotations to the map.
                            self.mapView.addAnnotations(annotations)
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    
                }
            }
        }
    
    }
    
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle! {
                
                UIApplication.shared.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
                
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logOut()
        UdacityClient.sharedInstance().deleteSession(self)
    
    }

    @IBAction func refreshButtonPressed(_ sender: Any) {
        
        print("refresh button pressed")
        self.activityIndicator.startAnimating()
        mapView.removeAnnotations(mapView.annotations)
        
        UdacityClient.sharedInstance().getStudentInformations(self) { (studentInformations, error) in
            
            self.mapView.delegate = self
            
            if let error = error {
                print(error)
                
            } else {
                
                if let studentInformations = studentInformations {
                    
                    DispatchQueue.global(qos: .background).async {
                        
                        // We will create an MKPointAnnotation for each dictionary in "locations". The
                        // point annotations will be stored in this array, and then provided to the map view.
                        var annotations = [MKPointAnnotation]()
                        
                        for information in studentInformations {
                            
                            // Notice that the float values are being used to create CLLocationDegree values.
                            // This is a version of the Double type.
                            let lat = CLLocationDegrees(information.latitude)
                            let long = CLLocationDegrees(information.longitude)
                            
                            // The lat and long are used to create a CLLocationCoordinates2D instance.
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            let first = information.firstName
                            let last = information.lastName
                            let mediaURL = information.mediaURL
                            
                            // Here we create the annotation and set its coordiate, title, and subtitle properties
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = coordinate
                            annotation.title = "\(first) \(last)"
                            annotation.subtitle = mediaURL
                            
                            // Finally we place the annotation in an array of annotations.
                            annotations.append(annotation)
                        }
                        
                        DispatchQueue.main.async {
                            // When the array is complete, we add the annotations to the map.
                            self.mapView.addAnnotations(annotations)
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    
                }
            }
        }
        
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        // Get Student Information by using UdacityClient
        UdacityClient.sharedInstance().getStudentInformation(self) { (success, error) in
            
            performUIUpdatesOnMain {
                if (success != nil) {
                    
                    // Present AddLocationVC
                    let storyboard = UIStoryboard (name: "Main", bundle: nil)
                    let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                    
                    // hostViewController
                    self.navigationController?.pushViewController(addLocationVC, animated: true)
                    
                } else {
                    
                    self.getAlertView(title: "Failed to Add Student Information", error: error! as! String)
                    
                }
            }
        }
    }
}


