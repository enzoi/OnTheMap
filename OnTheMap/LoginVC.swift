//
//  LoginVC.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import UIKit
import Foundation
import FacebookCore
import FacebookLogin

class LoginVC: UIViewController, LoginButtonDelegate {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var user_id: String?
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        // appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // configureUI()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
        
        debugTextLabel.text = ""
        
        // Facebook Login Button Setup
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        loginButton.frame = CGRect(x: 16, y: view.frame.height-55, width: view.frame.width-32, height: 35)
        view.addSubview(loginButton)
        
        loginButton.delegate = self
        
        // If logged in with Facebook access token, navigate to LocationMapVC
        if AccessToken.current != nil {
            self.postSessionWithFB()
            self.completeLogin()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        print("logged out of facebook")
    }
    
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("successfully logged in")
        
        // Get Public User Data Using Access Token
        self.postSessionWithFB()
        self.completeLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    @IBAction func loginPressed(_ sender: Any) {
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            // posting a session
            postSession()
        }
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        
        let webViewController = storyboard!.instantiateViewController(withIdentifier: "URLWebViewVC") as! URLWebViewVC
        let signupURL: String = "https://www.udacity.com/account/auth#!/signup"
        UIApplication.shared.open(URL(string: signupURL)!)
        
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: Udacity Get a Session
    
    private func postSessionWithFB() {
    
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
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed."
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
        
            let json = try? JSONSerialization.jsonObject(with: newData, options: []) as! [String: Any]
            
            if let dictionary = json {
                if let account = dictionary["account"] as? [String: Any] {
                    // access individual value in dictionary
                    
                    self.getPublicUserData(user_id: account["key"] as! String)
                    
                }
            }
        }
        
        task.resume()
    }
    
    private func postSession() {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(self.usernameTextField.text!)\", \"password\": \"\(self.passwordTextField.text!)\"}}".data(using: String.Encoding.utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                    self.debugTextLabel.text = "Login Failed."
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
                    
                    self.getPublicUserData(user_id: account["key"] as! String)
                    
                }
            }

            self.completeLogin()
        }
        
        // Start the request
        task.resume()
    }
    
    private func getPublicUserData(user_id: String) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(user_id)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            let json = try? JSONSerialization.jsonObject(with: newData!, options: []) as! [String: Any]
            
            if let dictionary = json {
                if let account = dictionary["user"] as? [String: Any] {
                    // access individual value in dictionary
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.udacityClient.key["uniqueKey"] = (account["key"] as? String)!
                    appDelegate.udacityClient.firstName = (account["first_name"] as? String)!
                    appDelegate.udacityClient.lastName = (account["last_name"] as? String)!

                }
                
            }
        }
        
        task.resume()
    
    }
    
}

// MARK: - LoginVC: UITextFieldDelegate

extension LoginVC: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            logoImageView.isHidden = true
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y = 0
            logoImageView.isHidden = false
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
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    
}

// MARK: - LoginVC (Configure UI)

private extension LoginVC {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
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

// MARK: - LoginVC (Notifications)

private extension LoginVC {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

