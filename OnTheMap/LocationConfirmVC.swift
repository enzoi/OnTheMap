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

    private func getStudentInformation() {
        
        

        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/")!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.httpBody = "{\"\(user_id)\"}}".data(using: String.Encoding.utf8)
        
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
            
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            // self.completeLogin()
        }
        
        // Start the request
        task.resume()
    }
    

    @IBAction func finishButtonPressed(_ sender: Any) {
        // Create Student Information instant)
//        let dictionary = [String: Any]()
//        let objectID: String = UUID().uuidString
//        let uniqueKey: String = "12345678910"
//        let firstName: String = ""
//        let lastName: String = ""
//        let latitude: Double = self.latitude
//        let longitude: Double = self.longitude
//        let mediaURL: String = self.website
//        let createdAt: String  ex) "createdAt":"2017-06-15T06:44:24.225Z"
//        let updatedAt: String  ex) "updatedAt":"2017-06-15T06:44:24.225Z"
        
        // Get user data to update
        getStudentInformation()
        
        // Post data with the new location using Udacity API

        
        
        // go back to location map view
        self.navigationController?.popToRootViewController(animated: true)
    }
}
