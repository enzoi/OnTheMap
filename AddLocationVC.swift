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

    var coordinate = 0
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }

    @IBAction func findLocationButtonPressed(_ sender: Any) {
        
        userDidTapView(self)
        
        if locationTextField.text!.isEmpty {
            debugTextLabel.text = "Location is Empty."
        } else if websiteTextField.text!.isEmpty {
            debugTextLabel.text = "Website is Empty."
        } else {
            setUIEnabled(false)
            
            // Get location info (lat, long) from text field
            if let array = locationTextField.text?.components(separatedBy: ",") {
                self.latitude = (array[0].trimmingCharacters(in: .whitespaces) as NSString).doubleValue
                self.longitude = (array[1].trimmingCharacters(in: .whitespaces) as NSString).doubleValue
            } else {
                debugTextLabel.text = "Invalid Coordinate"
            }
            
            let regexp = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
            if let range = websiteTextField.text?.range(of:regexp, options: .regularExpression) {
                let result = websiteTextField.text?.substring(with:range)
                self.website = result!
            } else {
                debugTextLabel.text = "Invalid Website"
            }
            
            performSegue(withIdentifier: "LocationConfirm", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // pass data from text field to LocationConfirmVC
        let controller = segue.destination as! LocationConfirmVC
        controller.latitude = self.latitude
        controller.longitude = self.longitude
        controller.website = self.website
        
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
