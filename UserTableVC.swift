//
//  UserTableVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class StudentInformationTableViewCell: UITableViewCell {
    
    // @IBOutlet weak var studentInformationTableView: UITableView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
}


class UserTableVC: UITableViewController {
    
    var alertController: UIAlertController?
    var studentInformations: [StudentInformation] = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                print("Could not parse the data as JSON: '\(data)'")
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
            }
            
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
        
        let webViewController = storyboard!.instantiateViewController(withIdentifier: "URLWebViewVC") as! URLWebViewVC
        webViewController.studentInformation = studentInformations[(indexPath as NSIndexPath).row]
        
        if let website = webViewController.studentInformation?.mediaURL {
            
            let regexp = "((https)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
            if let range = website.range(of:regexp, options: .regularExpression) {
                let validURL = website.substring(with:range)
                let request = URLRequest(url: URL(string: validURL)!)
                webViewController.request = request
                print("Valid?")
                
            }  else {
                // print error message
                print("Alert")
                self.alertController = UIAlertController(title: "Invalid URL", message: "Website", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
            
                self.alertController!.addAction(dismissAction)
                self.present(self.alertController!, animated: true, completion: nil)
            }
        
            present(webViewController, animated: true, completion: nil)
        }
    }
}
