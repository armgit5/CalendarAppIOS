//
//  ViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 8/18/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//


import UIKit

class ViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    // date and time data
    @IBOutlet weak var dateTextField: UITextField!
    var selectedDate = ""
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    
    // search bar
    var companyData: [String]?
    var companyId: Int?
    @IBOutlet weak var companyTextField: UITextField!
    
    // location picker view
    var pickerData = [""]
    var pickerLocation: String?
    var pickerLocationId: Int?
    var pickerLocationIdDict: [String: Int]?
    @IBOutlet weak var myPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        companyTextField.delegate = self
        companyTextField.text = "test"
        
        // picker view
        myPicker.dataSource = self
        myPicker.delegate = self
        
    }
    
    // MARK: - uipicker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return pickerData.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerLocation = pickerData[row]
        pickerLocationId = self.pickerLocationIdDict![self.pickerLocation!]
        print(pickerLocation, terminator: "")
        print(pickerLocationId, terminator: "")
    }

    // MARK: - Get locations
    
    func getLocations(companyId: Int) {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("locations") {
            companies in
            if let comArray = companies {
                dispatch_async(dispatch_get_main_queue()) {
                    let comArrayObj = Location(dictArray: comArray, companyId: companyId)
                    
                    self.pickerData = comArrayObj.locationArray
                    self.pickerLocation = self.pickerData.first
                    
                    self.pickerLocationIdDict = comArrayObj.locationDict
                    self.pickerLocationId = self.pickerLocationIdDict![self.pickerLocation!]
                    self.myPicker.reloadAllComponents()
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
            let initDate : NSDate? = formatter.dateFromString(dateTextField.text!)
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
                print(returnMessage, terminator: "")
            }
        }
    }
    
    // MARK: - unwind company from company table view
    
    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if segue.sourceViewController.isKindOfClass(SearchTableViewController) {
            let searchController = segue.sourceViewController as! SearchTableViewController
            if searchController.parentCompany != nil {
                companyTextField.text = searchController.parentCompany
                companyId = searchController.parentCompanyId
                getLocations(companyId!)
            }
        }
    }
    
}


