//
//  Location.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/9/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

struct Location {
    
    // Location Picker
    
    var pickerLocationId: Int?
    
    // Parsing

    var rawLocationData: [[String: AnyObject]]?
    var locationArray: [String]?
    var locationDict: [String: Int]?
    var allLocationDict: [String: Int]?
    
    init() {
        pickerLocationId = 0
    }
    
    init(dictArray: [[String: AnyObject]]) {
        self.rawLocationData = dictArray
        self.allLocationDict = [String: Int]()
        makeLocationArray()
    }
    
    init(dictArray: [[String: AnyObject]], companyId: Int) {
        self.rawLocationData = dictArray
        self.locationDict = [String: Int]()
        self.locationArray = [String]()
        makeLocationArray(companyId)
    }
    
    mutating func makeLocationArray(_ companyId: Int) {
        for location in rawLocationData! {
            if let companyIdKey = location["company_id"] as? Int {
                if companyIdKey == companyId {
                    if let locName = location["name"] as? String {
                        self.locationArray!.append(locName)
                        if let locationId = location["id"] as? Int {
                            self.locationDict![locName] = locationId
                        }
                    }
                }
            }
        }
    }
    
    mutating func makeLocationArray() {
        for location in rawLocationData! {
            if let locName = location["name"] as? String {
                if let locationId = location["id"] as? Int {
                    self.allLocationDict![locName] = locationId
                }
            }
        }
        
    }
    
    
}
