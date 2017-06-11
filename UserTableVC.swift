//
//  UserTableVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit

class StudentLocationTableViewCell: UITableViewCell {
    
    // @IBOutlet weak var studentLocationTableView: UITableView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
}


class UserTableVC: UITableViewController {

    var studentLocations: [StudentLocation] = [StudentLocation]()
    
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
            self.studentLocations = StudentLocation.locationsFromResults(results)
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
        return studentLocations.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // get cell type
        let cellReuseIdentifier = "StudentLocationTableViewCell"
        let studentLocation = studentLocations[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! StudentLocationTableViewCell
        
        // set cell defaults
        print(studentLocation)
        cell.studentNameLabel!.text = studentLocation.firstName
        cell.mediaURLLabel!.text = studentLocation.mediaURL
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let webViewController = storyboard!.instantiateViewController(withIdentifier: "URLWebViewVC") as! URLWebViewVC
        webViewController.studentLocation = studentLocations[(indexPath as NSIndexPath).row]
        present(webViewController, animated: true, completion: nil)

    }

}
