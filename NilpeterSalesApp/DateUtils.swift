//
//  DateUtils.swift
//  iDoctors
//
//  Created by Valerio Ferrucci on 02/10/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import Foundation

extension Date {
    
    // -> Date System Formatted Medium
    func ToDateMediumString() -> NSString? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
//        formatter.dateStyle = .MediumStyle;
//        formatter.timeStyle = .NoStyle;
        return formatter.string(from: self) as NSString?
    }
}
