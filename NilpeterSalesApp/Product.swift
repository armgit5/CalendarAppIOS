//
//  Product.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/22/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import Foundation

struct Product {
    
    // product pickers
    var productPickerIdArray: [Int]?
    var otherProductPickerIdArray: [Int]?
    
    // Parsing
    var rawProductData: [[String: AnyObject]]?
    var nilpeterProductArray: [String]?
    var otherProductArray: [String]?
    var productDict: [String: Int]?
    
    init() {
        productPickerIdArray = [Int]()
        otherProductPickerIdArray = [Int]()
    }
    
    init(dictArray: [[String: AnyObject]]) {
        self.nilpeterProductArray = []
        self.otherProductArray = []
        self.rawProductData = dictArray
        self.productDict = [String: Int]()
    
        makeProductArray()
    }
    
    mutating func makeProductArray() {
        for product in rawProductData! {
            if let productName = product["name"] as? String {
                if let typeId = product["type_id"] as? Int {
                    if typeId == 1 {
                        self.nilpeterProductArray!.append(productName)
                    } else {
                        self.otherProductArray!.append(productName)
                    }
                }
                let productId = product["id"] as? Int
                productDict![productName] = productId
            }
            
        }
    }
    
}