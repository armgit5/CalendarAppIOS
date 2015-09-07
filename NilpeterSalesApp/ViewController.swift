//
//  ViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 8/18/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//


import UIKit

class ViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    // date and time data
    @IBOutlet weak var dateTextField: UITextField!
    var selectedDate = ""
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    var companyData: [String]?

    
    // search bar
    @IBOutlet weak var companyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        companyTextField.delegate = self
        
        getComapnies()
    }
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            
                if let comArray = companies {
                dispatch_async(dispatch_get_main_queue()) {
                    let comArrayObj = Company(dictArray: comArray)
                    self.companyData = comArrayObj.companyArray
//                    println(self.companyData)
                }
            }
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - DatePicker popup
    
    func resign() {
        dateTextField.resignFirstResponder()
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "toATable" {
//            let secondCtrl = segue.destinationViewController as? SearchTableViewController
////            secondCtrl?.parentVC = self
//        }
//    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        
        
        if (textField === dateTextField) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            
            let initDate : NSDate? = formatter.dateFromString(dateTextField.text)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        } else if textField == companyTextField {
            performSegueWithIdentifier("toATable", sender: self)
            return true
        } else {
            return true
        }
    }
       
    // MARK: - allday onoff
    
    @IBAction func allDayOnOff(sender: AnyObject) {
        if allDaySwitch.on {
            allDayStatus = 1
        } else {
            allDayStatus = 0
        }
    }
    
    
    // MARK: - post method
    
    @IBAction func postToArm(sender: AnyObject) {
        let scheduleService = ScheduleService()
        let body = "{\"date\": \"\(dateTextField)\", \"all_day\": \"\(allDayStatus)\"}"
        scheduleService.postSchedule(body) {
            status in
            if let returnMessage = status as String? {
                println(returnMessage)
            }
        }
        
    }
    
}


