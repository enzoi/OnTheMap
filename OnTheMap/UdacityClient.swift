//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 7/9/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation
import UIKit
import FacebookCore
import FacebookLogin

// MARK: - UdacityClient: NSObject

class UdacityClient : NSObject {
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // configuration object
    // var config = UdacityConfig()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // user info
    var key: [ String: String ] = [ "uniqueKey": "" ]
    var firstName: String = ""
    var lastName: String = ""
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }

    
    // MARK: POST SESSION
    
    func taskForPOSTSession(username: String, password: String, hostViewController: LoginVC, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    hostViewController.setUIEnabled(true)
                    hostViewController.getAlertView(title: "Failed to Post Session", message: "Session Error Message", error: error)
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
            //print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            let json = try? JSONSerialization.jsonObject(with: newData, options: []) as! [String: Any]
            
            if let dictionary = json {
                if let account = dictionary["account"] as? [String: Any] {
                    // access individual value in dictionary
                    
                    self.getPublicUserData(user_id: account["key"] as! String, hostViewController: hostViewController)
                    
                }
            }
        }
        
        // Start the request
        task.resume()
    
        return task

    }
    
    func taskForPOSTSessionWithFB(completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let accessToken = AccessToken.current
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken);\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    // self.setUIEnabled(true)
                    // self.getAlertView(error: error)
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
        
        return task

    }
    
    // MARK: POST METHOD
    
    func taskForPOSTMethod(completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {

        let accountKey = try? JSONSerialization.data(withJSONObject: UdacityClient.sharedInstance().key, options: [])
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // request.httpBody = "{\"uniqueKey\": \"\(String(describing: dict["uniqueKey"]))\", \"firstName\": \"\(String(describing: dict["firstName"]))\", \"lastName\": \"\(String(describing: dict["lastName"]))\", \"mediaURL\": \"\(String(describing: dict["mediaURL"]))\",\"latitude\": \(String(describing: dict["latitude"])), \"longitude\": \(String(describing: dict["longitude"]))}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                
                print(error)
                // self.getAlertView(error: error)
                
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
        
        return task
    }
    
    // MARK: PUT METHOD
    
    func taskForPUTMethod(object_id: String) {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(object_id)"
        let url = URL(string: urlString)
        print("urlString", urlString)
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var httpBodyString = ""
        /* if let uniqueKey = dict["uniqueKey"], let mapString = dict["mapString"], let firstName = dict["firstName"], let lastName = dict["lastName"], let latitude = dict["latitude"], let longitude = dict["longitude"], let mediaURL = dict["mediaURL"] {
            httpBodyString = "{\"uniqueKey\": \"\(uniqueKey)\", \"mapString\": \"\(mapString)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        } */
        
        // request.httpBody = httpBodyString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                
                print(error)
                // self.getAlertView(title: <#String#>, error: error as! String)
                
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
        }
        
        task.resume()
    }
    
    
    

    // MARK: HELPERS
    
//    func getStudentInformations() {
//        
//        // Get Student Locations
//        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=400&order=-updatedAt")!)
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//        
//        let session = URLSession.shared
//        
//        let task = session.dataTask(with: request as URLRequest) { data, response, error in
//            if error != nil { // Handle error...
//                
//                // self.getAlertView(error: error as! String)
//                
//                return
//            }
//            // print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
//            
//            /* Parse the data */
//            let parsedResult: [String:AnyObject]!
//            do {
//                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
//            } catch {
//                print("Could not parse the data as JSON: '\(String(describing: data))'")
//                return
//            }
//            
//            /* GUARD: Did Udacity return an error? */
//            if let _ = parsedResult["status_code"] as? Int {
//                print("Udacity returned an error. See the Status Code")
//                return
//            }
//            
//            /* GUARD: Is the "results" key in parsedResult? */
//            guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
//                print("Cannot find key results")
//                return
//            }
//
//            /* Use the data! */
//            let _ = StudentInformation.locationsFromResults(results)
//        }
//        
//        task.resume()
//        
//    }


    // get public user data from udacity
    func getPublicUserData(user_id: String, hostViewController: LoginVC) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(user_id)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                hostViewController.getAlertView(title: "Faied to Get User Data", message: "Get public user data message", error: error as! String)
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            let json = try? JSONSerialization.jsonObject(with: newData!, options: []) as! [String: Any]
            
            if let dictionary = json {
                if let account = dictionary["user"] as? [String: Any] {
                    // access individual value in dictionary
                    UdacityClient.sharedInstance().key["uniqueKey"] = (account["key"] as? String)!
                    UdacityClient.sharedInstance().firstName = (account["first_name"] as? String)!
                    UdacityClient.sharedInstance().lastName = (account["last_name"] as? String)!
                    
                    print(UdacityClient.sharedInstance().key["uniqueKey"])
                    print(UdacityClient.sharedInstance().firstName)
                    print(UdacityClient.sharedInstance().lastName)
                }
                
            }
        }
        
        task.resume()
        
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}

