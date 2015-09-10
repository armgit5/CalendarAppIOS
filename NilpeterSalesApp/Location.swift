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
    
    var locationDictArray: [[String: AnyObject]]
    var locationArray: [String] = []
    var locationIdDict: [String: Int]
    
    init(dictArray: [[String: AnyObject]], companyId: Int) {
        self.locationDictArray = dictArray
        self.locationIdDict = [String: Int]()
        makeLocationArray(companyId)
    }
    
    mutating func makeLocationArray(companyId: Int) {
        for location in locationDictArray {
            if let companyIdKey = location["company_id"] as? Int {
                if companyIdKey == companyId {
                    if let locName = location["name"] as? String {
                        locationArray.append(locName)
                        if let locationId = location["id"] as? Int {
                            locationIdDict[locName] = locationId
                        }
                    }
                }
            }
            
        }
    }
    
}
