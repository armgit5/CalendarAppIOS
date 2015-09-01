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
        self.scheduleBaseURL = NSURL(string: "http://localhost:3000/api/schedules")
    }
    
//    func getSchedule(scheduleQuery: String, completion: (CurrentWeather? -> Void)) {
//        if let forecaseURL = NSURL(string: scheduleInfo, relativeToURL: forecaseBaseURL) {
//            
//            let networkOperation = NetworkOperation(url: forecaseURL)
//            
//            networkOperation.downloadJSONFromURL {
//                JSONDictionary in
//                let currentWeather = self.currentWeatherFromJSON(JSONDictionary)
//                completion(currentWeather)
//            }
//            
//        } else {
//            println("counldn't construct valid url")
//        }
//    }
//    
//    func currentWeatherFromJSON(jsonDictionary: [String: AnyObject]?) -> CurrentWeather? {
//        if let currentWeatherDictionary = jsonDictionary?["currently"] as? [String: AnyObject] {
//            return CurrentWeather(weatherDictionary: currentWeatherDictionary)
//        } else {
//            println("JSON dictionary returned nil for currently key")
//            return nil
//        }
//    }

    
    
}