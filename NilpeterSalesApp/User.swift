//
//  User.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 10/5/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import Foundation


var prefs: UserDefaults! = UserDefaults.standard
//

struct User {
    static var email = "ios@nilpeter.com"
    static var password = "ios123"
    static var userId = 1
    static var headingBaseURL = "http://localhost:3000/"
//    static let headingBaseURL = "http://nilpeter.herokuapp.com/"
//    static var headingBaseURL =  "http://nilpeter-service.herokuapp.com/"
//    static var headingBaseURL = ""
//    static let headingBaseURL =  "http://nilpeterit.herokuapp.com/"
//    static let headingBaseURL =  "http://arm-calendar.herokuapp.com/"
    //static let headingBaseURL =  "http://arm-calendar-apitest.herokuapp.com/"
    
    static var isSet = false
    
    static func setUrl() {
        headingBaseURL = prefs.string(forKey: "ServerName")!
        isSet = true
    }
}

