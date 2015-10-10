//
//  SearchbarDelegate.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/4/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//
//  * Note: not working well because it cannot return the id from selected textfield
//  Planning to impliment static variables in the models to store data statically later on


import Foundation
import UIKit

class NilpeterProductDelegate: NSObject, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var product: Product?
    var testarray = ["one", "two", "three"]
    let nilpeterProductView = UIPickerView()
    var name = ""
    var textF = UITextField()
    
    override init() {
        super.init()
        product = Product()
        self.getProducts()
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        nilpeterProductView.delegate = self
        textField.inputView = nilpeterProductView
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.text = name
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        //        return (location?.locationArray?.count)!
        return testarray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //        return (location?.locationArray)![row]
        return testarray[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        name = testarray[row]
    }
    
   
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.text = name
        textField.resignFirstResponder()
        return true
    }
    
    func getProducts() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("products") {
            products in
            if let productArray = products {
                dispatch_async(dispatch_get_main_queue()) {
                    let productArrayObj = Product(dictArray: productArray)
                    self.product?.nilpeterProductArray = productArrayObj.nilpeterProductArray
                    self.product?.otherProductArray = productArrayObj.otherProductArray
                    self.product?.productDict = productArrayObj.productDict
                    print(self.product?.nilpeterProductArray)
                }
            }
            
        }
    }
    
    
}