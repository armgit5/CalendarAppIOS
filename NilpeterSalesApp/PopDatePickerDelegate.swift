//
//  PopDatePickerDelegate.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/3/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation
import UIKit

class PopDatePickerDelegate {
    
//    func resign() {
//        dateTextField.resignFirstResponder()
//    }
//    
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        
//        if (textField === dateTextField) {
//            resign()
//            let formatter = NSDateFormatter()
//            formatter.dateFormat = "dd-MM-yyyy HH:mm"
//            // formatter.dateStyle = .MediumStyle
//            // formatter.timeStyle = .NoStyle
//            let initDate : NSDate? = formatter.dateFromString(dateTextField.text)
//            
//            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
//                
//                // here we don't use self (no retain cycle)
//                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
//                
//            }
//            
//            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
//            return false
//        }
//        else {
//            return true
//        }
//    }

}