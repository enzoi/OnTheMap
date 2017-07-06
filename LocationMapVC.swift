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
    var studentInformations: [StudentInformation] = [StudentInformation]()
    var results: [String: Any]?
    
    // The map. See the setup in the Storyboard file. Note particularly that the view controller
    // is set up as the map view's delegate.
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStudentInformations()
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    private func getStudentInformations() {
        
        mapView.delegate = self
        
        // Get Student Locations
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=400&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            // print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            /* Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            if let _ = parsedResult["status_code"] as? Int {
                print("Udacity returned an error. See the Status Code")
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                print("Cannot find key results")
                return
            }
            
            /* Use the data! */
            self.studentInformations = StudentInformation.locationsFromResults(results)
            
            DispatchQueue.global(qos: .background).async {
                
                self.activityIndicator.startAnimating()
                // We will create an MKPointAnnotation for each dictionary in "locations". The
                // point annotations will be stored in this array, and then provided to the map view.
                var annotations = [MKPointAnnotation]()
                
                for information in self.studentInformations {
                    
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
        
        task.resume()
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
    
    private func deleteSession() {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            // print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            self.dismiss(animated: true, completion: nil)
        }
        
        task.resume()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logOut()
        deleteSession()
    
    }

    @IBAction func refreshButtonPressed(_ sender: Any) {
        
        print("refresh button pressed")
        getStudentInformations()
        
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        
        // Get Student Information
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let studentInformations = appDelegate.studentInformations
        let uniqueKey = appDelegate.udacityClient.key["uniqueKey"]
        
        var urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey!)%22%7D"
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error!)")
                
                self.alertController = UIAlertController(title: "Request Error", message: "There was an error with your request", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                
                self.alertController!.addAction(dismissAction)
                self.present(self.alertController!, animated: true, completion: nil)
                
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                
                self.alertController = UIAlertController(title: "Failed Response", message: "Your request returned a status code other than 2xx!", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                
                self.alertController!.addAction(dismissAction)
                self.present(self.alertController!, animated: true, completion: nil)
                
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                
                self.alertController = UIAlertController(title: "Data Error", message: "No data was returned by the request!", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                
                self.alertController!.addAction(dismissAction)
                self.present(self.alertController!, animated: true, completion: nil)

                return
            }
            
            /* Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                print("Cannot find key results") // no existing data
                // Present AddLocationVC
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                self.navigationController?.pushViewController(addLocationVC, animated: true)
                return
            }
            
            /* Use the data! */
            let studentInformation = StudentInformation.locationsFromResults(results)
            self.results = results[0]
            
            // Alert if location info already exists on the account
            self.alertController = UIAlertController(title: "Location already exists", message: "Would you like to overwrite the data?", preferredStyle: .alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: {(action:UIAlertAction) in
                
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                
                /* Send the data to next VC */
                addLocationVC.results = results[0]
                self.navigationController?.pushViewController(addLocationVC, animated: true)
                
            })
            let cancelAction = UIAlertAction(title: "Dismiss", style: .default)
            
            self.alertController!.addAction(overwriteAction)
            self.alertController!.addAction(cancelAction)
            
            self.present(self.alertController!, animated: true, completion: nil)
            
        }
        // Start the request
        task.resume()
    }
}
