//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 7/12/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UdacityClient {
    
    // MARK: GET STUDENT INFORMATION (When ADD button pressed from LocationMapVC, UserTableVC)
    
    func getStudentInformation(_ hostViewController: UIViewController, completionHandlerForGETStudentInformation: @escaping (_ result: Int?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let uniqueKey = UdacityClient.sharedInstance().key["uniqueKey"]
        
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
                
                let alertController = UIAlertController(title: "Request Error", message: "There was an error with your request", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
                alertController.addAction(dismissAction)
                
                hostViewController.present(alertController, animated: true, completion: nil)
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
                hostViewController.navigationController?.pushViewController(addLocationVC, animated: true)
                return
            }
            
            /* Use the data! */
            _ = StudentInformation.locationsFromResults(results)
            
            // Alert if location info already exists on the account
            let alertController = UIAlertController(title: "Location already exists", message: "Would you like to overwrite the data?", preferredStyle: .alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: {(action:UIAlertAction) in
                
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                
                /* Send the data to next VC */
                addLocationVC.results = results[0]
                hostViewController.navigationController?.pushViewController(addLocationVC, animated: true)
                
            })
            
            let cancelAction = UIAlertAction(title: "Dismiss", style: .default)
            
            alertController.addAction(overwriteAction)
            alertController.addAction(cancelAction)
            
            hostViewController.present(alertController, animated: true, completion: nil)
            
        }
        // Start the request
        task.resume()
        
        return task
    }

    
    // MARK: GET STUDENT INFORMATIONS (LocationMapVC, UserTableVC)
    
    func getStudentInformations(_ hostViewController: UIViewController, completionHandlerForGET: @escaping (_ results: [StudentInformation]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        // Get Student Locations
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=400&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                
                hostViewController.getAlertView(title: "Session Error", error: error as! String)
                
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
            if let results = parsedResult["results"] as? [[String:AnyObject]] {
                
                let studentInformations = StudentInformation.locationsFromResults(results)
                completionHandlerForGET(studentInformations, nil)
                
            } else {
                completionHandlerForGET(nil, NSError(domain: "getStudentInformation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentInformation"]))
            }
    
        }
        task.resume()
        
        return task
        
    }
    
    
    // MARK: POST SESSION
    
    func postSession(_ hostViewController: LoginVC, completionHandlerForLogin: @escaping (_ result: Int?, _ error: Error?) -> Void) {
        
        if let username = hostViewController.usernameTextField.text, let password = hostViewController.passwordTextField.text {
            
            /* Make the request */
            let _ = UdacityClient.sharedInstance().taskForPOSTSession(username: username, password: password, hostViewController: hostViewController) { (result, error) in
                
                if let error = error {
                    print(error)
                    completionHandlerForLogin(nil, error)
                
                } else {
                    if let result = result as? Int {
                        completionHandlerForLogin(result, nil)
                    } else {
                        completionHandlerForLogin(nil, NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postSession"]))
                    }
                }
            }
        } else {
            
            hostViewController.getAlertView(title: "Login Error", error: "Username or Password Empty")
        
        }
        
    }
    
    // MARK: POST SESSION WITH FACEBOOK
    
    func postSessionWithFB(_ hostViewController: LoginVC, accessToken: String?, completionHandlerForLogin: @escaping (_ result: Int?, _ error: Error?) -> Void) {
        
        if let accessToken = accessToken {
            
            /* Make the request */
            let _ = UdacityClient.sharedInstance().taskForPOSTSessionWithFB(accessToken, hostViewController: hostViewController) { (result, error) in
               
                if let error = error {
                    print(error)
                    hostViewController.getAlertView(title: "Failed to Post Session with Facebook", error: error as! String)
                } else {
                    if let result = result as? Int {
                        completionHandlerForLogin(result, nil)
                    } else {
                        completionHandlerForLogin(nil, NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postSession"]))
                    }
                }
            }
        } else {
            
            hostViewController.getAlertView(title: "Login Error", error: "Access Token Error")
            
        }
    
    }
    
    
    // MARK: POST STUDENT INFORMATION
    
    // func postStudentInformation using taskForPOSTMethod
    
    
    
    
    // MARK: PUT STUDENT INFORMATION
    
    // func putStudentInformation using taskForPUTMethod
    
    
    
    
    // MARK: DELETE SESSION
    
    func deleteSession(_ hostViewController: UIViewController) {
        
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
                
                // self.getAlertView(title: <#String#>, error: error as! String, )
                
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            // print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            hostViewController.dismiss(animated: true, completion: nil)
        }
        
        task.resume()
    }
    
}
