//
//  ViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 8/18/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//


import UIKit

class ViewController: UITableViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var myDatePicker: UIDatePicker?
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var dateTextField: UITextField!
    var selectedDate = ""
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        
        getComapnies()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = dateFormatter.stringFromDate(myDatePicker!.date)
        self.selectedDate = strDate
    }
    
    @IBAction func allDayOnOff(sender: AnyObject) {
        if allDaySwitch.on {
            allDayStatus = 1
        } else {
            allDayStatus = 0
        }
    }
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
                println(companies)
        }
    }
    
    func resign() {
        dateTextField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        if (textField === dateTextField) {
            resign()
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
//            formatter.dateStyle = .MediumStyle
//            formatter.timeStyle = .NoStyle
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
    
    
    @IBAction func postToArm(sender: AnyObject) {
        
        let session = NSURLSession.sharedSession()
        let urlString = "http://localhost:3000/api/schedules"
        let url = NSURL(string: urlString)!
        let body = "{\"date\": \"\(selectedDate)\", \"all_day\": \"\(allDayStatus)\"}"
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding);
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) { (data: NSData!, response: NSURLResponse!, error: NSError!) in
            
            if error != nil {
                // Handle error...
                println(error)
            } else {
                println("successfully submitted \(self.selectedDate)")
                /* 5. Parse the data */
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as? NSDictionary
                
                /* 6. Use the data! */
                if let status = parsedResult?["message"] as? String {
                    println(status)
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    
}


