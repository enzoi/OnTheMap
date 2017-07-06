//
//  UserTableVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import SafariServices
import FacebookCore
import FacebookLogin

class StudentInformationTableViewCell: UITableViewCell {
    
    var alertController: UIAlertController?
    
    // @IBOutlet weak var studentInformationTableView: UITableView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
}


class UserTableVC: UITableViewController {
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var studentInformations: [StudentInformation] = [StudentInformation]()
    
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
        
        self.activityIndicator.startAnimating()
        self.tabBarController?.tabBar.isHidden = false
        self.getStudentInformations()
        
    }
    
    private func getStudentInformations() {
        
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil { // Handle error...
                return
            }
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
            
            /* Parse the data */
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
            
            /* GUARD: Did TheMovieDB return an error? */
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
            performUIUpdatesOnMain {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
            
        }
        
        task.resume()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentInformations.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // get cell type
        let cellReuseIdentifier = "StudentInformationTableViewCell"
        let studentInformation = studentInformations[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! StudentInformationTableViewCell
        
        // set cell defaults
        print(studentInformation)
        cell.studentNameLabel!.text = studentInformation.firstName
        cell.mediaURLLabel!.text = studentInformation.mediaURL
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentInformation = studentInformations[(indexPath as NSIndexPath).row]
        let website = studentInformation.mediaURL
        let regexp = "((https)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
            
        if let range = website.range(of:regexp, options: .regularExpression) {
            let validURL = website.substring(with:range)
            UIApplication.shared.open(URL(string: validURL)!)
                
        }  else {
            // print error message
            print("Alert")
            self.alertController = UIAlertController(title: "Invalid URL", message: "Website", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
            
            self.alertController!.addAction(dismissAction)
            self.present(self.alertController!, animated: true, completion: nil)
        }
    }

    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        // Get Student Information
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let studentInformations = appDelegate.studentInformations
        let uniqueKey = appDelegate.udacityClient.key["uniqueKey"]
        print(uniqueKey)
        
        var urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey!)%22%7D"
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
                return
            }
            print("first results:", results[0])
            
            /* Use the data! */
            let studentInformation = StudentInformation.locationsFromResults(results)
            
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
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logOut()
        deleteSession()
        
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
        
    }
    
}
