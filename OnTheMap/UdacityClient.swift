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

    var key: [String: String] = [ "uniqueKey": "" ]
    var firstName: String = ""
    var lastName: String = ""
    var objectId: String = ""
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }

    
    // MARK: POST SESSION
    
    func taskForPOSTSession(username: String, password: String, hostViewController: LoginVC, completionHandlerForPOST: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
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
                    hostViewController.getAlertView(title: "Failed to Post Session", error: error)
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
            
            self.convertDataWithCompletionHandler(newData, hostViewController: hostViewController, completionHandlerForConvertData: completionHandlerForPOST)

        }
        
        // Start the request
        task.resume()
    
        return task

    }
    
    func taskForPOSTSessionWithFB(_ hostViewController: LoginVC, accessToken: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        var accessToken: String = ""
        if let token = AccessToken.current {
            accessToken = token.authenticationToken
        }
        
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
                    hostViewController.setUIEnabled(true)
                    hostViewController.getAlertView(title: "Facebook Login Failed", error: error)
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
            
            completionHandlerForPOST(data as AnyObject, nil)
            
        }
        
        task.resume()
        
        return task

    }
    
    // MARK: POST METHOD
    
    func taskForPOSTMethod(_ hostViewController: LocationConfirmVC, dict: StudentInformation, completionHandlerForPOST: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        print("POST METHOD")
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        let url = URL(string: urlString)
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(String(describing: self.key["uniqueKey"]))\", \"firstName\": \"\(self.firstName))\", \"lastName\": \"\(self.lastName)\", \"mediaURL\": \"\(String(describing: dict.mediaURL))\",\"latitude\": \(String(describing: dict.latitude)), \"longitude\": \(String(describing: dict.longitude))}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                
                print(error)
                hostViewController.getAlertView(title: "POST Error", error: error)
                
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
            
            self.convertDataWithCompletionHandler(data, hostViewController: hostViewController, completionHandlerForConvertData: completionHandlerForPOST)
            print(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)
            
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: PUT METHOD
    
    func taskForPUTMethod(_ hostViewController: LocationConfirmVC, object_id: String, dict: StudentInformation, completionHandlerForPUT: @escaping (_ result: [String: Any]?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        let uniqueKey = UdacityClient.sharedInstance().key["uniqueKey"]
        let firstName = UdacityClient.sharedInstance().firstName
        let lastName = UdacityClient.sharedInstance().lastName
        let _ = getPublicUserData(user_id: uniqueKey!, hostViewController: hostViewController)
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(object_id)"
        let url = URL(string: urlString)
        print("urlString", urlString)
        
        let request = NSMutableURLRequest(url: url!)
        
        request.httpMethod = "PUT"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var httpBodyString = "{\"uniqueKey\": \"\(String(describing: uniqueKey!))\", \"mapString\": \"\(String(describing: dict.mapString))\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\", \"mediaURL\": \"\(String(describing: dict.mediaURL))\",\"latitude\": \(String(describing: dict.latitude)), \"longitude\": \(String(describing: dict.longitude))}"
        
        request.httpBody = httpBodyString.data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                
                print(error)
                hostViewController.getAlertView(title: "Overwrite Data Faield", error: error)       
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
            
            self.convertDataWithCompletionHandler(data, hostViewController: hostViewController, completionHandlerForConvertData: completionHandlerForPUT)
            
        }

        task.resume()
        
        return task
    }
    

    // MARK: HELPERS

    // get public user data from udacity
    func getPublicUserData(user_id: String, hostViewController: UIViewController) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(user_id)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                hostViewController.getAlertView(title: "Faied to Get User Data", error: error as! String)
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

                }
                
            }
        }
        
        task.resume()
        
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, hostViewController: UIViewController, completionHandlerForConvertData: (_ result: [String: Any]?, _ error: Error?) -> Void) {
        
        var parsedResult: [String: Any]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        } catch {
            print(error)
        }
        
        if let dictionary = parsedResult {
            if let account = dictionary["account"] as? [String: Any] {
                // access individual value in dictionary
                self.getPublicUserData(user_id: account["key"] as! String, hostViewController: hostViewController)
                
            }
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}

