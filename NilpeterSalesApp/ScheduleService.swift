//
//  ScheduleService.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/1/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

struct ScheduleService {
    let scheduleBaseURL: URL?
    typealias ScheduleServiceCompletion = ([[String: AnyObject]]?) -> Void
    
    init() {
        
        let headingBastURL = User.headingBaseURL + "api/"
        self.scheduleBaseURL = URL(string: headingBastURL)
    }
    
    func getSchedule(_ scheduleQuery: String, idString: String?, completion: @escaping ScheduleServiceCompletion) {
        if let scheduleURL = URL(string: scheduleQuery, relativeTo: scheduleBaseURL) {
            
            let networkOperation = NetworkOperation(url: scheduleURL)
            networkOperation.downloadJSONFromURL(idString) {
                JSONDictionary in
                completion(JSONDictionary)
            }
        } else {
            print("counldn't construct valid url")
        }
    }
    
    func postSchedule(_ scheduleBody: String, postId: String?, postMethod: String, completion: @escaping (String?) -> Void) {
        if let scheduleURL = URL(string: "schedules/", relativeTo: scheduleBaseURL) {
            
            let networkOperation = NetworkOperation(url: scheduleURL)
            if let id = postId {
                networkOperation.postBodyToURL(scheduleBody, postId: id, postMethod: postMethod) {
                    JSONDictionary in
                    completion(JSONDictionary)
                }
            } else {
                networkOperation.postBodyToURL(scheduleBody, postId: nil, postMethod: postMethod) {
                    JSONDictionary in
                    completion(JSONDictionary)
                }
            }
           
            
        } else {
            print("counldn't construct valid url")
        }
    }
    
    
    
}
