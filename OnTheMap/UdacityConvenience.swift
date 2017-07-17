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
import FacebookCore
import FacebookLogin

extension UdacityClient {
    
    // MARK: GET STUDENT INFORMATION (When ADD button pressed from LocationMapVC, UserTableVC)
    
    func getStudentInformation(_ hostViewController: UIViewController, completionHandlerForGET: @escaping (_ result: StudentInformation?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let uniqueKey = UdacityClient.sharedInstance().key["uniqueKey"]
        print("uniqueKey:", uniqueKey)
        
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
            
            if let results = parsedResult["results"] as? [[String:Any]] {
                
                print("getStudentInformation.results:", results)
                let studentInformation = StudentInformation(dictionary: results[0])
                completionHandlerForGET(studentInformation, nil)
                
            } else {
                
                completionHandlerForGET(nil, error)
                // hostViewController.getAlertView(title: "Failed to Add Student Information", error: error! as! String)

            }
            
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

            // if an error occurs, print it
            func displayError(_ error: String) {
                print(error)
                
                let alertController = UIAlertController(title: "Request Error", message: "Unable to complete the task!!!", preferredStyle: .alert)
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
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            /* GUARD: Did Udacity return an error? */
            if let _ = parsedResult["status_code"] as? Int {
                print("Udacity returned an error. See the Status Code")
                return
            }
            
            if let results = parsedResult["results"] as? [[String:AnyObject]] {
                
                let studentInformations = StudentInformation.locationsFromResults(results)
                completionHandlerForGET(studentInformations, nil)
                
            } else {
                completionHandlerForGET(nil, error)
            }
    
        }
        task.resume()
        
        return task
        
    }
    
    
    // MARK: POST SESSION
    
    func postSession(_ hostViewController: LoginVC, completionHandlerForLogin: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        if let username = hostViewController.usernameTextField.text, let password = hostViewController.passwordTextField.text {
            
            /* Make the request */
            let _ = UdacityClient.sharedInstance().taskForPOSTSession(username: username, password: password, hostViewController: hostViewController) { (result, error) in
                
                if error != nil {
                    print(error)
                    completionHandlerForLogin(nil, error)
                
                } else { // success
                    if let result = result {
                        print(result)
                        let account = result["account"] as! [String:Any]
                        let key = account["key"] as! String
                        print("key:", key)
                        self.getPublicUserData(user_id: key, hostViewController: hostViewController)
                        completionHandlerForLogin(result, nil)
                    } else {
                        completionHandlerForLogin(nil, error)
                    }
                }
            }
        } else {
            
            hostViewController.getAlertView(title: "Login Error", error: "Username or Password Empty")
        
        }
        
    }
    
    // MARK: POST SESSION WITH FACEBOOK
    
    func postSessionWithFB(_ hostViewController: LoginVC, completionHandlerForLogin: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        var accessToken: String = ""
        if let token = AccessToken.current {
            accessToken = token.authenticationToken

            /* Make the request */
            let _ = UdacityClient.sharedInstance().taskForPOSTSessionWithFB(hostViewController, accessToken: accessToken) { (result, error) in
               
                if error != nil {
                    print(error)
                    completionHandlerForLogin(nil, error)
                    // hostViewController.getAlertView(title: "Failed to Post Session with Facebook", error: error as! String)
                } else {
                    if let result = result {
                        let account = result["account"] as! [String:Any]
                        let key = account["key"] as! String
                        self.getPublicUserData(user_id: key, hostViewController: hostViewController)
                        completionHandlerForLogin(result, nil)
                    } else {
                        completionHandlerForLogin(nil, error)
                    }
                }
            }
        } else {
            
            hostViewController.getAlertView(title: "Login Error", error: "Access Token Error")
            
        }
    
    }
    
    
    // MARK: POST STUDENT INFORMATION
    
    func postStudentInformation(_ hostViewController: UIViewController, dict: StudentInformation, completionHandlerForPOST: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        /* Make the request */
        let _ = UdacityClient.sharedInstance().taskForPOSTMethod(hostViewController as! LocationConfirmVC, dict: dict) { (result, error) in
            
            /* Send the desired value(s) to completion handler */
            if let error = error {
                completionHandlerForPOST(nil, error)
                hostViewController.getAlertView(title: "Failed to Post Student Information", error: error as! String)
            } else {
                if let result = result {
                    completionHandlerForPOST(result, nil)
                } else {
                    completionHandlerForPOST(nil, error)
                }
            }
        }
    }
    
    // MARK: PUT STUDENT INFORMATION
    
    func putStudentInformation(_ hostViewController: UIViewController, object_id: String, dict: StudentInformation, completionHandlerForPUT: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        /* Make the request */
        let _ = UdacityClient.sharedInstance().taskForPUTMethod(hostViewController as! LocationConfirmVC, object_id: object_id, dict: dict) { (result, error) in
            
            /* Send the desired value(s) to completion handler */
            if error != nil {
                completionHandlerForPUT(nil, error)
                hostViewController.getAlertView(title: "Failed to Overwrite Student Information", error: error as! String)
            } else {
                if let result = result {
                    completionHandlerForPUT(result, nil)
                } else {
                    completionHandlerForPUT(nil, error)
                }
            }
            
        }
    }
    
    
    
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
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            hostViewController.dismiss(animated: true, completion: nil)
        }
        
        task.resume()
    }
    
}
