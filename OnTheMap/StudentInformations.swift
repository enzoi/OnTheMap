//
//  StudentInformations.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 7/12/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

class StudentInformations {
    
    let studentInformations = [StudentInformation]()
    static let sharedInstance = StudentInformations()
    private init() {} //This prevents others from using the default '()' initializer for this class.
    
}
