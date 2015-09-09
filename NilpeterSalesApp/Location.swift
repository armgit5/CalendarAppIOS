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
    
    init(dictArray: [[String: AnyObject]]) {
        self.locationDictArray = dictArray
        self.locationIdDict = [String: Int]()
        makeLocationArray()
    }
    
    mutating func makeLocationArray() {
        for location in locationDictArray {
            if let locName = location["name"] as? String {
                locationArray.append(locName)
                let locId = location["id"] as! Int
                locationIdDict[locName] = locId
            }
            
        }
    }
    
}
