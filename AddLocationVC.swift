//
//  AddLocationVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddLocationVC: UIViewController {

    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var alertController: UIAlertController?
    var results: StudentInformation?
    var mapString: String = ""
    var website: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var manager = CLLocationManager()
    lazy var geocoder = CLGeocoder()

    var keyboardOnScreen = false
    
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var findLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
        debugTextLabel.text = ""
        
        // Activity Indicator Set up
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.lightGray
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    @IBAction func findLocationButtonPressed(_ sender: Any) {
        
        userDidTapView(self)
        
        /* GUARD: Is the location input empty? */
        guard let mapString = locationTextField.text, !mapString.isEmpty else {
            self.getAlertView(title: "Input Error", error: "Location information is empty!!!")
            return
        }
        
        /* GUARD: Is the website input empty? */
        guard let website = websiteTextField.text, !website.isEmpty else {
            self.getAlertView(title: "Input Error", error: "URL information is empty!!!")
            return
        }
        
        /* Validate URL input by user */
        // validating url using regular expression (code below created based on the solution from http://urlregex.com/)
        let regexp = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        guard let range = websiteTextField.text?.range(of:regexp, options: .regularExpression) else {
            self.getAlertView(title: "Input Error", error: "Invalid URL...Please enter valid URL!!")
            return
        }
        
        self.website = websiteTextField.text!.substring(with:range)
        self.mapString = locationTextField.text!
        
        // Update View
        self.activityIndicator.startAnimating()

        // Geocode Address String
        geocoder.geocodeAddressString(self.mapString) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }

    }
    
    private func getStudentInformation() -> StudentInformation {
        
        let uniqueKey: String = UdacityClient.sharedInstance().key["uniqueKey"]!
        let firstName: String = UdacityClient.sharedInstance().firstName
        let lastName: String = UdacityClient.sharedInstance().lastName
        let latitude: Double = self.latitude
        let longitude: Double = self.longitude
        let mediaURL: String = self.website
        let mapString: String = self.mapString
        
        return StudentInformation(dictionary: ["uniqueKey": uniqueKey, "firstName": firstName, "lastName": lastName, "latitude": latitude, "longitude": longitude, "mediaURL": mediaURL, "mapString": mapString])
        
    }
    
    // forward geocoding (code below created based on the solution from https://cocoacasts.com/forward-and-reverse-geocoding-with-clgeocoder-part-1/)
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        print("function called")
        self.activityIndicator.stopAnimating()
        
        if error != nil {
            
            // Alert if geocoding fails
            self.alertController = UIAlertController(title: "Geocoding Failed", message: "Please enter a valid address or check your Internet connection!!", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Dismiss", style: .cancel)
            
            self.alertController!.addAction(okayAction)
            self.present(self.alertController!, animated: true, completion: nil)
            
            return
            
        } else { // Geocoding sucessfully executed
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
                
                if self.results?.uniqueKey != nil { // Data already exists
                    
                    // Update existing data with new user input
                    self.results?.mapString = self.mapString
                    self.results?.latitude = self.latitude
                    self.results?.longitude = self.longitude
                    self.results?.mediaURL = self.website
                    
                } else {
                    
                    // Create new Student Information and send it to LocationConfirmVC
                    self.results = getStudentInformation()
                    self.results?.mapString = self.mapString
                    self.results?.latitude = self.latitude
                    self.results?.longitude = self.longitude
                    self.results?.mediaURL = self.website
                    
                }
                
                // Get the storyboard and LocationConfirmVC. Pass data to the VC
                let storyboard = UIStoryboard (name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "LocationConfirmVC") as! LocationConfirmVC
                
                controller.results = self.results!
                
                self.navigationController?.pushViewController(controller,animated: true)
                
            } else {
                self.getAlertView(title: "No Matching Location Found", error: error as! String)
            }
    
        }
    }
}

// MARK: - AddLocationVC: UITextFieldDelegate

extension AddLocationVC: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification) - 80
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
        }
    }
    
    func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height - 55
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(locationTextField)
        resignIfFirstResponder(websiteTextField)
    }
    
}

// MARK: - AddLocationVC (Configure UI)

private extension AddLocationVC {
    
    func setUIEnabled(_ enabled: Bool) {
        locationTextField.isEnabled = enabled
        websiteTextField.isEnabled = enabled
        findLocationButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // find location button alpha
        if enabled {
            findLocationButton.alpha = 1.0
        } else {
            findLocationButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(locationTextField)
        configureTextField(websiteTextField)
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - AddLocationVC (Notifications)

private extension AddLocationVC {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
