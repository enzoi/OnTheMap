
//
//  Constants.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - Constants

struct Constants {
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).cgColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).cgColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    // FIX: As of Swift 2.2, using strings for selectors has been deprecated. Instead, #selector(methodName) should be used.
    /*
     // MARK: Selectors
     struct Selectors {
     static let KeyboardWillShow: Selector = "keyboardWillShow:"
     static let KeyboardWillHide: Selector = "keyboardWillHide:"
     static let KeyboardDidShow: Selector = "keyboardDidShow:"
     static let KeyboardDidHide: Selector = "keyboardDidHide:"
     }
     */
}
