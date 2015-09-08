//
//  ViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 8/18/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//


import UIKit

class ViewController: UITableViewController, UITextFieldDelegate, SearchTableViewControllerDelegate {
    
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    // date and time data
    @IBOutlet weak var dateTextField: UITextField!
    var selectedDate = ""
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    
    // search bar
    var companyData: [String]?
    @IBOutlet weak var companyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        companyTextField.delegate = self
        companyTextField.text = "test"
        getComapnies()
    }
    
    // MARK: - Get companies
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            
                if let comArray = companies {
                dispatch_async(dispatch_get_main_queue()) {
                    let comArrayObj = Company(dictArray: comArray)
                    self.companyData = comArrayObj.companyArray
                }
            }
            
        }
    }
    
    func addCompany(company: String) {
        companyTextField.text = company
        tableView.reloadData()
    }
    
    // MARK: - DatePicker popup
    
    func resign() {
        dateTextField.resignFirstResponder()
    }
    
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
    
    // MARK: - unwind company from company table view
    
    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if segue.sourceViewController.isKindOfClass(SearchTableViewController) {
            let searchController = segue.sourceViewController as! SearchTableViewController
            if searchController.parentApple != nil {
                companyTextField.text = searchController.parentApple
            }
        }
    }
    
}


