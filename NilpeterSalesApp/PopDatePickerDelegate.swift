//
//  PopDatePickerDelegate.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/3/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation
import UIKit

class PopDatePickerDelegate: NSObject, UITextFieldDelegate {
    
    
    var dateTextField: UITextField?
    var selectedDate = ""
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    var insideView: UIViewController?

    
    init(textField: UITextField, viewCont: UIViewController) {
        super.init()
        dateTextField = textField
        popDatePicker = PopDatePicker(forTextField: dateTextField!)
        insideView = viewCont
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField === dateTextField) {
            dateTextField!.resignFirstResponder()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            
            let initDate : Date? = formatter.date(from: dateTextField!.text!)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                
            }
            
            popDatePicker?.pick(insideView!, initDate: initDate, dataChanged: dataChangedCallback)
            
            return false
        }
        else {
            return true
        }
    }

}
