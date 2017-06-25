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
    
    var results: Dictionary<String, Any> = [:]
    var website: String = ""
    var annotation = MKPointAnnotation()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.latitude = self.results["latitude"] as! Double
        self.longitude = self.results["longitude"] as! Double
        print(self.latitude, self.longitude)
        
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
            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let accountKey = try? JSONSerialization.data(withJSONObject: appDelegate.udacityClient.key, options: [])
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(String(describing: dict["uniqueKey"]))\", \"firstName\": \"\(String(describing: dict["firstName"]))\", \"lastName\": \"\(String(describing: dict["lastName"]))\", \"mediaURL\": \"\(String(describing: dict["mediaURL"]))\",\"latitude\": \(String(describing: dict["latitude"])), \"longitude\": \(String(describing: dict["longitude"]))}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
            
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {

                    }
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    displayError("There was an error with your request: \(error!)")
                    return
                }
            
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    displayError("Your request returned a status code other than 2xx!")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    displayError("No data was returned by the request!")
                    return
                }
                
                //let range = Range(5..<data.count)
                // let newData = data.subdata(in: range) /* subset response data! */
                print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
                
        }
        
        task.resume()
        
    }
    
    private func putStudentInformation(object_id: String, dict: [String : Any]) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(object_id)"
        let url = URL(string: urlString)
        print("urlString", urlString)
        
        let request = NSMutableURLRequest(url: url!)
            
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let httpBodyString = "{\"uniqueKey\": \"\(dict["uniqueKey"]!)\", \"mapString\": \"\(dict["mapString"]!)\", \"firstName\": \"\(dict["firstName"]!)\", \"lastName\": \"\(dict["lastName"]!)\", \"mediaURL\": \"\(dict["mediaURL"]!)\",\"latitude\": \(dict["latitude"]!), \"longitude\": \(dict["longitude"]!)}"
        print(httpBodyString)
        request.httpBody = httpBodyString.data(using: String.Encoding.utf8)
        print(request.httpBody!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()

    }
    
}
