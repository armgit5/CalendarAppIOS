//
//  Location.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/9/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

import UIKit

struct Location {
    
    // Location Picker
    
    var pickerLocationName: String?
    var pickerLocationId: Int?
    var pickerLocationIdDict: [String: Int]?
    
    // Parsing

    var rawLocationData: [[String: AnyObject]]?
    var locationArray: [String]?
    var locationDict: [String: Int]?
    
    init() {
        pickerLocationName = ""
        pickerLocationId = 0
        pickerLocationIdDict = [String: Int]()
    }
    
    init(dictArray: [[String: AnyObject]], companyId: Int) {
        self.rawLocationData = dictArray
        self.locationDict = [String: Int]()
        self.locationArray = [String]()
        makeLocationArray(companyId)
    }
    
    mutating func makeLocationArray(companyId: Int) {
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
    
}
