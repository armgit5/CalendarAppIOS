//
//  ScheduleService.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/1/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

struct ScheduleService {
    let scheduleBaseURL: NSURL?
    
    init() {
        let headingBastURL =  "http://localhost:3000/api/"
        self.scheduleBaseURL = NSURL(string: headingBastURL)
    }
    
    func getSchedule(scheduleQuery: String, completion: ([[String: AnyObject]]? -> Void)) {
        if let scheduleURL = NSURL(string: scheduleQuery, relativeToURL: scheduleBaseURL) {
            
            let networkOperation = NetworkOperation(url: scheduleURL)
            
            networkOperation.downloadJSONFromURL {
                JSONDictionary in
                completion(JSONDictionary)
            }
            
        } else {
            println("counldn't construct valid url")
        }
    }
    
}