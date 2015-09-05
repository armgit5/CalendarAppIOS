//
//  SearchbarDelegate.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/4/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation
import UIKit

class SearchbarDelegate: UIViewController, UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        performSegueWithIdentifier("toATable", sender: self)
        return true
    }
}