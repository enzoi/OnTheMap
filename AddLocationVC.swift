//
//  AddLocationVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import MapKit

class AddLocationVC: UIViewController {

    var results: [String: Any]?
    var studdentInformation: StudentInformation?
    var coordinate: String = ""
    var website: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    var manager = CLLocationManager()

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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    @IBAction func findLocationButtonPressed(_ sender: Any) {
        
        userDidTapView(self)
        
        guard let coord = locationTextField.text, !coord.isEmpty else {
            debugTextLabel.text = "Location is Empty."
            return
        }
        
        guard let website = websiteTextField.text, !website.isEmpty else {
            debugTextLabel.text = "Website is Empty."
            return
        }
            
        // Get location info (lat, long) from text field
        guard let coordinate = locationTextField.text, !coordinate.isEmpty else {
            debugTextLabel.text = "Invalid Coordinate...Please enter valid Coordinate"
            return
        }
        
        guard let url = websiteTextField.text, !url.isEmpty else {
            debugTextLabel.text = "Invalid URL...Please enter valid URL"
            return
        }
        
        // Get a coordinate from locationTextField
        let array = coordinate.components(separatedBy: ",")
        self.latitude = (array[0].trimmingCharacters(in: .whitespaces) as NSString).doubleValue
        self.longitude = (array[1].trimmingCharacters(in: .whitespaces) as NSString).doubleValue
            
        // Validate the coordinate
        if (latitude < -90 || latitude > 90) || (longitude < -180 || longitude > 180) {
            debugTextLabel.text = "Invalid Coordinate"
            return
        }
        
        // Validate URL
        let regexp = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        guard let range = websiteTextField.text?.range(of:regexp, options: .regularExpression) else {
            debugTextLabel.text = "Invalid Website"
            return
        }
        
        self.website = websiteTextField.text!.substring(with:range)
        
        if self.results != nil {
            
            // Update new data
            self.results?["latitude"] = self.latitude
            self.results?["longitude"] = self.longitude
            self.results?["mediaURL"] = self.website
            print("put:", self.results!)
            
        } else {
            
            // Create new Student Information and send it to LocationConfirmVC 
            self.results = getStudentInformationDictionary()
            self.results?["latitude"] = self.latitude
            self.results?["longitude"] = self.longitude
            self.results?["mediaURL"] = self.website
            print("post:", self.results!)
            
        }

        // Pass data to next VC
        // Get the storyboard and LocationConfirmVC
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LocationConfirmVC") as! LocationConfirmVC
        
        controller.results = self.results!
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        controller.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller,animated: true)

    }
    
    private func getStudentInformationDictionary() -> [String: Any] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let uniqueKey: String = appDelegate.udacityClient.key["uniqueKey"]!
        let firstName: String = appDelegate.udacityClient.firstName
        let lastName: String = appDelegate.udacityClient.lastName
        let latitude: Double = self.latitude
        let longitude: Double = self.longitude
        let mediaURL: String = self.website
        
        return ["uniqueKey": uniqueKey, "firstName": firstName, "lastName": lastName, "latitude": latitude, "longitude": longitude, "mediaURL": mediaURL] as [String: Any]
        
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
            // view.frame.origin.y -= keyboardHeight(notification)
            // logoImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            // view.frame.origin.y += keyboardHeight(notification)
            // logoImageView.isHidden = false
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
        return keyboardSize.cgRectValue.height
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
