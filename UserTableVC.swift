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
    
    // @IBOutlet weak var studentInformationTableView: UITableView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var mediaURLLabel: UILabel!
    
}

class UserTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var studentInformations: [StudentInformation] = [StudentInformation]()
    
    @IBOutlet var tableView: UITableView!
    
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
        
        let _ = UdacityClient.sharedInstance().getStudentInformations(self) { (studentInformations, error) in
            
            if let studentInformations = studentInformations {
                
                self.studentInformations = studentInformations
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } else {
                print(error ?? "empty error")
            }
        }
    }
    

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentInformations.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        
        // Get Student Information by using UdacityClient
        let _ = UdacityClient.sharedInstance().getStudentInformation(self) { (results, error) in
            
            performUIUpdatesOnMain {
                if error != nil {
                    self.getAlertView(title: "Failed to Add Student Information", error: error as! String)
                } else {

                    if (results?.objectId != nil) {
                        
                        // Alert if location info already exists on the account
                        let alertController = UIAlertController(title: "Location already exists", message: "Would you like to overwrite the data?", preferredStyle: .alert)
                        let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: {(action:UIAlertAction) in
                            
                            let storyboard = UIStoryboard (name: "Main", bundle: nil)
                            let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                            
                            /* Send the data to next VC */
                            addLocationVC.results = results

                            self.navigationController?.pushViewController(addLocationVC, animated: true)
                            
                        })
                        
                        let cancelAction = UIAlertAction(title: "Dismiss", style: .default)
                        
                        alertController.addAction(overwriteAction)
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    } else {
                        
                        // Present AddLocationVC
                        let storyboard = UIStoryboard (name: "Main", bundle: nil)
                        let addLocationVC = storyboard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                        self.navigationController?.pushViewController(addLocationVC, animated: true)
                        
                    }
                }
            }
        }

    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logOut()
        
        UdacityClient.sharedInstance().deleteSession(self)
        
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        
        print("refresh button pressed")
        self.activityIndicator.startAnimating()
        self.tabBarController?.tabBar.isHidden = false
        
        let _ = UdacityClient.sharedInstance().getStudentInformations(self) { (studentInformations, error) in
            
            if let studentInformations = studentInformations {
                
                self.studentInformations = studentInformations
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            } else {
                self.getAlertView(title: "Refresh Error", error: "Unable to Refresh Data!!!")
            }
        }
        
    }
    
}
