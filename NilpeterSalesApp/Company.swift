//
//  Company.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/4/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation
import UIKit

struct Company {
    
    var companyDictArray: [[String: AnyObject]]
    var companyArray: [String] = []
    var companyIdDict: [String: Int]
    
    init(dictArray: [[String: AnyObject]]) {
        self.companyDictArray = dictArray
        self.companyIdDict = [String: Int]()
        makeCompanyArray()
    }
    
    mutating func makeCompanyArray() {
        for company in companyDictArray {
            if let comName = company["name"] as? String {
                companyArray.append(comName)
                let comId = company["id"] as! Int
                companyIdDict[comName] = comId
            }
            
        }
    }
  
}
