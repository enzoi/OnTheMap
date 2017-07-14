//
//  UdacityLocation.swift
//  OnTheMap
//
//  Created by Yeontae Kim on 6/6/17.
//  Copyright © 2017 YTK. All rights reserved.
//

import Foundation

// MARK: - Movie

struct StudentInformation {
    
    // MARK: Properties
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mediaURL: String
    let mapString: String
    
    // MARK: Initializers
    
    init(dictionary: [String:Any]) {

        objectId = dictionary["objectId"] as! String
        uniqueKey = dictionary["uniqueKey"] as? String ?? ""
        firstName = dictionary["firstName"] as? String ?? ""
        lastName = dictionary["lastName"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
        mediaURL = dictionary["mediaURL"] as? String ?? ""
        mapString = dictionary["mapString"] as? String ?? ""

    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentInformations = StudentInformations.sharedInstance.studentInformations
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            studentInformations.append(StudentInformation(dictionary: result))
        }
     
        return studentInformations
    }
    
}
