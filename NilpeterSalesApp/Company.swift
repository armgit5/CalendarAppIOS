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
    
    // View Controller
    var companyData: [String]?
    var companyId: Int?
    
    // Search Table
    var companies: [String] = []
    var filteredCompanies = [String]()
    var parentCompany: String?
    var parentCompanyDict: [String: Int]?
    var parentCompanyId: Int?
    
    // Parsing
    var rawCompanyData: [[String: AnyObject]]?
    var companyArray: [String]?
    var companyDict: [String: Int]?
    
    init() {
        
    }
    
    init(dictArray: [[String: AnyObject]]) {
        self.companyArray = []
        self.rawCompanyData = dictArray
        self.companyDict = [String: Int]()
        makeCompanyArray()
    }
    
    mutating func makeCompanyArray() {
        for company in rawCompanyData! {
            if let comName = company["name"] as? String {
                companyArray!.append(comName)
                let comId = company["id"] as! Int
                companyDict![comName] = comId
            }
            
        }
    }
  
}
