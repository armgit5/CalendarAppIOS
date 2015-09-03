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
    
    // search bar
    let appleProducts = ["Mac","Apple 5","iPhone","Apple Watch","iPad","Apple2","Apple3"]
    var filteredAppleProducts = [String]()
    var resultSearchController = UISearchController()
    @IBOutlet weak var companyTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        popDatePicker = PopDatePicker(forTextField: dateTextField)
//        dateTextField.delegate = self
        companyTextField.delegate = self
        
        
        // getComapnies()
        
//        self.resultSearchController = UISearchController(searchResultsController: nil)
//        self.resultSearchController.searchResultsUpdater = self
//        self.resultSearchController.dimsBackgroundDuringPresentation = false
//        self.resultSearchController.searchBar.sizeToFit()
//        
//        self.tableView.tableHeaderView = self.resultSearchController.searchBar
//        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        performSegueWithIdentifier("toATable", sender: self)
        return true
    }
    
    // MARK: - DatePicker popup
    
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

       
    // MARK: - allday onoff
    
    @IBAction func allDayOnOff(sender: AnyObject) {
        if allDaySwitch.on {
            allDayStatus = 1
        } else {
            allDayStatus = 0
        }
    }
    
    // MARK: - get method
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            println(companies)
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
    
    
    // MARK: - search bar
    
//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (self.resultSearchController.active)
//        {
//            return self.filteredAppleProducts.count
//        }
//        else
//        {
//            return self.appleProducts.count
//        }
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as? UITableViewCell
//        
//        if (self.resultSearchController.active)
//        {
//            cell!.textLabel?.text = self.filteredAppleProducts[indexPath.row]
//            
//            return cell!
//        }
//        else
//        {
//            cell!.textLabel?.text = self.appleProducts[indexPath.row]
//            
//            return cell!
//        }
//    }
//    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        var apple = ""
//        
//        if (self.resultSearchController.active) {
//            apple = self.filteredAppleProducts[indexPath.row]
//            println("call")
//        } else {
//            println("nocall")
//            apple = self.appleProducts[indexPath.row]
//        }
//        
//        println("result \(self.resultSearchController.active) , index row = \(indexPath.row), apple = \(apple), filter = \(filteredAppleProducts), appleprods = \(appleProducts)")
//        
//        
//    }
//    
//    
//    
//    func updateSearchResultsForSearchController(searchController: UISearchController) {
//        
//        self.filteredAppleProducts.removeAll(keepCapacity: false)
//        
//        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
//        let array = (self.appleProducts as NSArray).filteredArrayUsingPredicate(searchPredicate)
//        self.filteredAppleProducts = array as! [String]
//        //println(self.filteredAppleProducts)
//        self.tableView.reloadData()
//    }

    
    
}


