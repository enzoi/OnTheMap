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
    
    var dictionary: [String: AnyObject] = [:]
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
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let studentInformations = appDelegate.studentInformations
        let accountKey = try? JSONSerialization.data(withJSONObject: appDelegate.udacityClient.key, options: .prettyPrinted) // JSON
        
        var urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        // urlString = urlString.appending("?where=")
        let url = URL(string: urlString)

        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        print("request", request)
        
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
            // print("data", NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            /* Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            if let _ = parsedResult["status_code"] as? Int {
                print("Udacity returned an error. See the Status Code")
                return
            }
            
            /* GUARD: Is the "results" key in parsedResult? */
            guard let results = parsedResult["results"] as? [String:AnyObject] else {
                print("Cannot find key results")
                return
            }
            
            if let uniqueKey = results["uniqueKey"] as? String {
                if uniqueKey.characters.count == 0 {
                // Would like to overwrite existing information
                }
                self.alertOverwriteData()
            } else {
                // Create new information for the user
                // dictionary = studentInformations
                // postStudentInformation(uniqueKey, dictionary)
            }
        
        }
        
        // Start the request
        task.resume()
        
    }
    
    private func postStudentInformation() {
            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let studentInformations = appDelegate.studentInformations
        let accountKey = try? JSONSerialization.data(withJSONObject: appDelegate.udacityClient.key, options: [])
        
            
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=\(accountKey!)"
        print("urlString", urlString)
        let url = URL(string: urlString)
        print("url:", url)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        // request.httpBody = "{ StudentInformation JSON  }".data(using: String.Encoding.utf8)
            
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
                
        }
        
        task.resume()
        
    }
    
    // Alert if location info already exists on the account
    private func alertOverwriteData() {
        self.alertController = UIAlertController(title: "Location already exists", message: "Would you like to overwrite the data?", preferredStyle: .alert)
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: nil) // append
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel)
        
        self.alertController!.addAction(overwriteAction)
        self.alertController!.addAction(cancelAction)
        self.present(self.alertController!, animated: true, completion: nil)
    }

    @IBAction func finishButtonPressed(_ sender: Any) {
        // Create Student Information instant
//        let dictionary = [String: Any]()
//        let objectID: String = UUID().uuidString
//        let uniqueKey: String = "12345678910"
//        let firstName: String = ""
//        let lastName: String = ""
//        let latitude: Double = self.latitude
//        let longitude: Double = self.longitude
//        let mediaURL: String = self.website
//        let createdAt: String = createdAt ? createdAt : NSDate()  // Now  ex) "createdAt":"2017-06-15T06:44:24.225Z"
//        let updatedAt: String = NSDate() ex) "updatedAt":"2017-06-15T06:44:24.225Z"
        
        // Get user data to update
        getStudentInformation()
        

        
        // Post the new location using Udacity API with the user account key
        
        
        
        // go back to location map view
        self.navigationController?.popToRootViewController(animated: true)
    }
}
