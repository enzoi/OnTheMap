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
    let createdAt: String
    let updatedAt: String
    
    // MARK: Initializers
    
    init(dictionary: [String:AnyObject]) {
        objectId = dictionary["objectId"] as! String
        uniqueKey = dictionary["uniqueKey"] as! String
        firstName = dictionary["firstName"] as? String ?? ""
        lastName = dictionary["lastName"] as? String ?? ""
        latitude = dictionary["latitude"] as? Double ?? 0.0
        longitude = dictionary["longitude"] as? Double ?? 0.0
        mediaURL = dictionary["mediaURL"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? String ?? ""
        updatedAt = dictionary["updatedAt"] as? String ?? ""
    }
    
    static func locationsFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var studentInformations = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            studentInformations.append(StudentInformation(dictionary: result))
        }
        
        return studentInformations
    }
    
}
