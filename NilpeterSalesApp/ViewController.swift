//
//  ViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 8/18/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//


import UIKit

class ViewController: UITableViewController, UITextFieldDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var dateTextField: UITextField!
    var selectedDate = ""
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    
    var friendArray = [FriendItem]()
    var filteredFriends = [FriendItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.friendArray += [FriendItem(name: "test")]
        self.friendArray += [FriendItem(name: "apple")]
        self.friendArray += [FriendItem(name: "itune")]
        self.friendArray += [FriendItem(name: "arm")]
        self.friendArray += [FriendItem(name: "mac")]
        self.friendArray += [FriendItem(name: "ipad")]
        self.friendArray += [FriendItem(name: "tree")]
        
        
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        
        getComapnies()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK - DatePicker popup
    
    func resign() {
        dateTextField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField === dateTextField) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            // formatter.dateStyle = .MediumStyle
            // formatter.timeStyle = .NoStyle
            let initDate : NSDate? = formatter.dateFromString(dateTextField.text)
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        }
        else {
            return true
        }
    }
    
    // MARK - allday onoff
    
    @IBAction func allDayOnOff(sender: AnyObject) {
        if allDaySwitch.on {
            allDayStatus = 1
        } else {
            allDayStatus = 0
        }
    }
    
    // MARK - get method
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            println(companies)
        }
    }
    
    // MARK - post method
    
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


