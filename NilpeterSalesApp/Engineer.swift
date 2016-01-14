//
//  Engineer.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 1/13/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import Foundation

struct Engineer {
    
    // Parsing
    static var rawEngineerData: [[String: AnyObject]] = [["":""]]
    static var engineerArray: [String] = []
    static var engineerDict: [String: Int] = ["":0]
    
    static var pickedEngineerNames: [String] = []
    static var pickedEngineerIds: [Int] = []
    
//    func makeEngineerArray() {
//        for product in rawEngineerData {
//            if let productName = product["name"] as? String {
//                if let typeId = product["type_id"] as? Int {
//                    if typeId == 1 {
//                        self.engineerArray!.append(productName)
//                    }
//                }
//                let productId = product["id"] as? Int
//                engineerDict![productName] = productId
//            }
//            
//        }
//    }
    
}