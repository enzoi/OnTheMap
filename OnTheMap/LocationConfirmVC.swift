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

    private func getStudentInformation(unique_id: [String: String]) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let studentInformations = appDelegate.studentInformations
        let uniqueKey = appDelegate.udacityClient.key["uniqueKey"]

        var urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey!)%22%7D"
        print("urlString", urlString)
        let url = URL(string: urlString)

        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
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
            
            print((response as? HTTPURLResponse)?.statusCode)
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
            
            // let range = Range(0..<data.count)
            // let newData = data.subdata(in: range) /* subset response data! */
            // print("data", NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            /* Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            if let _ = parsedResult["status_code"] as? Int {
                print("Udacity returned an error. See the Status Code")
                return
            }

            /* Is uniquekey in parsedResult? */
            if let results = parsedResult["results"] as? [[String:AnyObject]] {
                /* Use the data! */
                let studentInformation = StudentInformation.locationsFromResults(results)
                
                print("studentInformation", studentInformation)
                if studentInformation[0].uniqueKey != "" {
                    // self.dictionary = studentInformation[0]
                    self.alertOverwriteData() // Cancel or Post data
                }

            } else {
                print("Cannot find key results")
    
                // Create Student Information Dictionary
                self.dictionary = self.getStudentInformationDictionary()
                
                print("---------------------")
                // PUT existing data to Parse
                self.putStudentInformation(object_id: self.dictionary["objectId"] as! String, dict: self.dictionary)
            }

            self.dismiss(animated: true, completion: nil)
        
        }
        
        // Start the request
        task.resume()
        
    }
    
    private func postStudentInformation(dict: [String: AnyObject]) {
            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var urlString = ""
        do {
            let accountKey = try? JSONSerialization.data(withJSONObject: appDelegate.udacityClient.key, options: [])
            urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=\(accountKey!)"
        } catch {
            print(error.localizedDescription)
        }
        
        let url = URL(string: urlString)
        
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
    
    private func putStudentInformation(object_id: String, dict: [String: AnyObject]) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(object_id)"
        let url = URL(string: urlString)
        print(urlString, url)
        
        let request = NSMutableURLRequest(url: url!)
            
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(dict["uniqueKey"])\", \"firstName\": \"\(dict["firstName"])\", \"lastName\": \"\(dict["lastName"])\", \"mediaURL\": \"\(dict["mediaURL"])\",\"latitude\": \(dict["latitude"]), \"longitude\": \(dict["longitude"])}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }

    }
    
    private func getStudentInformationDictionary() -> [String: AnyObject] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let objectId: String = UUID().uuidString
        let uniqueKey: String = appDelegate.udacityClient.key["uniqueKey"]!
        let firstName: String = appDelegate.udacityClient.firstName
        let lastName: String = appDelegate.udacityClient.lastName
        let latitude: Double = self.latitude
        let longitude: Double = self.longitude
        let mediaURL: String = self.website
        let createdAt: String = ""  // ex) "createdAt":"2017-06-15T06:44:24.225Z"
        let updatedAt: String = String(describing: NSDate()) // ex) "updatedAt":"2017-06-15T06:44:24.225Z"
        
        return ["objectId": objectId, "uniqueKey": uniqueKey, "firstName": firstName, "lastName": lastName, "latitude": latitude, "longitude": longitude, "mediaURL": mediaURL, "createdAt": createdAt, "updatedAt": updatedAt] as [String: AnyObject]
        
    }
    
    // Alert if location info already exists on the account
    private func alertOverwriteData() {
        self.alertController = UIAlertController(title: "Location already exists", message: "Would you like to overwrite the data?", preferredStyle: .alert)
        let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: {(action:UIAlertAction) in
            self.postStudentInformation(dict: self.dictionary)
        })
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel)
        
        self.alertController!.addAction(overwriteAction)
        self.alertController!.addAction(cancelAction)
        self.present(self.alertController!, animated: true, completion: nil)
    }

    @IBAction func finishButtonPressed(_ sender: Any) {
       
        // Get user data from Parse to update
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        getStudentInformation(unique_id: appDelegate.udacityClient.key)
 
        // go back to location map view
        self.navigationController?.popToRootViewController(animated: true)
    }
}
