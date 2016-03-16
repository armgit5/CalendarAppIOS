//
//  ViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 8/18/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//


import UIKit

class ViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIWebViewDelegate {
    
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    // date and time data
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    
    var popDatePicker : PopDatePicker?
    var popEndDatePicker : PopDatePicker?
    
    // company
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var jobNumTextField: UITextField!
    @IBOutlet weak var machineTextField: UITextField!
    
    // products
    var product: Product?
    @IBOutlet var nilpeterProductTextField: UITextField!
    @IBOutlet var otherProductTextField: UITextField!
    var selectedProductName = [String]() // send back segue data
    var selectedOtherProductName = [String]() // send back segue data
    @IBOutlet weak var loadingNilpeterProducts: UILabel!
    @IBOutlet weak var loadingNilpeterIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingThirdIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingThirdLabel: UILabel!
    var productTimer = NSTimer()
    
    // engineer
    @IBOutlet weak var engineerTextField: UITextField!
    @IBOutlet weak var loadingEngineerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingEngineerLabel: UILabel!
    
    var engineerTimer = NSTimer()
    
    // Description
    @IBOutlet var descriptionTextField: UITextField!
    
    let webView: UIWebView = UIWebView()
    
    // Spinner
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    var updateText: UILabel!
    var welcome: UILabel!
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    @IBOutlet weak var chargeStatus: UIButton!
    var chargeStatusNum: Int = 0
    
    
    // User store
    var prefs: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User store
        // Check user session
        prefs = NSUserDefaults.standardUserDefaults()
        if prefs.integerForKey("Session") == 0 {
            self.performSegueWithIdentifier("showLogin", sender: self)
        }
       
        // disable table view selection
        self.tableView.allowsSelection = false
        
        // initialize company and location models
        product = Product()
        
        // location pickerview
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        popEndDatePicker = PopDatePicker(forTextField: endDateTextField)
        dateTextField.delegate = self
        endDateTextField.delegate = self
        companyTextField.delegate = self
        nilpeterProductTextField.delegate = self
        otherProductTextField.delegate = self
        engineerTextField.delegate = self
        descriptionTextField.delegate = self
        
        // UI Design
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.tabBarController?.tabBar.barTintColor = UIColor.redColor()
        self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        
        self.getProducts()
        productTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateProducts", userInfo: nil, repeats: true)
        self.getEngineers()
        engineerTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateEngineers", userInfo: nil, repeats: true)
        
        // Submitting spinner
        loadingLabel = UILabel.init(frame: CGRectMake(self.view.frame.size.width - 75, 0, 80, 35))
        loadingLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        loadingLabel.text = "Submitting..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.size.width - 130, 0, 80, 35)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        self.hideLoading()
        
        updateText = UILabel.init(frame: CGRectMake(self.view.frame.size.width - 150, 0, 150, 35))
        updateText.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        updateText.text = "Succesfully submitted!"
        view.addSubview(updateText)
        hideSubmitted()
        
        welcome = UILabel.init(frame: CGRectMake(10, 0, 175, 35))
        welcome.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        if let email = self.prefs.stringForKey("Email") {
            welcome.text = "Welcome \(email)"
        }
        view.addSubview(welcome)
                
        sendButton.enabled = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(self.prefs.integerForKey("Userid"))
        if let email = self.prefs.stringForKey("Email") {
            welcome.text = "Welcome \(email)"
        }
        downLoadJobNum(String(self.prefs.integerForKey("Userid")))
        
    }

    

    @IBAction func chargeButtonPressed(sender: AnyObject) {
        if chargeStatusNum == 0 {
            chargeStatus.setTitle("chargable", forState: .Normal)
        }
        if chargeStatusNum == 1 {
            chargeStatus.setTitle("non-chargable", forState: .Normal)
        }
    }
    
    // MARK: - UIPickerView Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    // MARK: - Get information from the cloud
    
    func showLoadProducts() {
        loadingNilpeterIndicator.startAnimating()
        loadingThirdIndicator.startAnimating()
        loadingNilpeterIndicator.hidden = false
        loadingNilpeterProducts.hidden = false
        loadingThirdIndicator.hidden = false
        loadingThirdLabel.hidden = false
        nilpeterProductTextField.userInteractionEnabled = false
        otherProductTextField.userInteractionEnabled = false
    }
    func hideLoadProducts() {
        loadingNilpeterIndicator.stopAnimating()
        loadingThirdIndicator.stopAnimating()
        loadingNilpeterIndicator.hidden = true
        loadingThirdIndicator.hidden = true
        loadingNilpeterProducts.hidden = true
        loadingThirdLabel.hidden = true
        nilpeterProductTextField.userInteractionEnabled = true
        otherProductTextField.userInteractionEnabled = true
    }
    
    func updateProducts() {
        getProducts()
        print("timer get products")
        
    }
   
    func getProducts() {
        showLoadProducts()
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("products", idString: nil) {
            products in
            if let productArray = products {
                dispatch_async(dispatch_get_main_queue()) {
                    let productArrayObj = Product(dictArray: productArray)
                    self.product?.nilpeterProductArray = productArrayObj.nilpeterProductArray
                    self.product?.otherProductArray = productArrayObj.otherProductArray
                    self.product?.productDict = productArrayObj.productDict
                    self.hideLoadProducts()
                    self.productTimer.invalidate()
                }
            }
        }
    }
    
    func showLoadEngineers() {
        loadingEngineerIndicator.startAnimating()
        loadingEngineerIndicator.hidden = false
        loadingEngineerLabel.hidden = false
        engineerTextField.userInteractionEnabled = false
    }
    func hideLoadEngineers() {
        loadingEngineerIndicator.stopAnimating()
        loadingEngineerIndicator.hidden = true
        loadingEngineerLabel.hidden = true
        engineerTextField.userInteractionEnabled = true
    }
    
    func updateEngineers() {
        getEngineers()
        print("timer get engineers")
        
    }
    
    func downLoadJobNum(idString: String) {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules/auto_jobnum/", idString: idString) {
            newJobNums in
            dispatch_async(dispatch_get_main_queue()) {
                if let validJobNums = newJobNums {
                    for newJobNum in validJobNums {
                        if let jobNum = newJobNum["newJobNum"] as? String {
                            self.jobNumTextField.text = jobNum
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getEngineers() {
        showLoadEngineers()
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("engineers", idString: nil) {
            engineers in
            Engineer.rawEngineerData.removeAll()
            Engineer.engineerArray.removeAll()
            Engineer.engineerDict.removeAll()
            if let engineerArray = engineers {
                dispatch_async(dispatch_get_main_queue()) {
                    for engineer in engineerArray {
                        if let engineertName = engineer["email"] as? String {
                            if engineertName == "admin@nilpeter.com" {
//                                print("don't add admin")
                            } else if engineertName == "ios@nilpeter.com" {
//                                print("don't add ios")
                            } else if engineertName == self.prefs.stringForKey("Email") {
//                                print("dont' add current user")
                            } else {
                                Engineer.engineerArray.append(engineertName)
                                if let engineerId = engineer["id"] as? Int {
                                    Engineer.engineerDict[engineertName] = engineerId
                                }
                            }
                        }
                    }
                    self.hideLoadEngineers()
                    self.engineerTimer.invalidate()
                    self.sendButton.enabled = true
//                    print(Engineer.engineerArray)
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == descriptionTextField {
            textField.resignFirstResponder()
            return true
        }
        return true
        
    }
    
    // MARK: - Text Field delegate
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
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
        } else if (textField === endDateTextField) {
                resign()
                let formatter = NSDateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm"
                let initDate : NSDate? = formatter.dateFromString(endDateTextField.text!)
                let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : NSDate, forTextField : UITextField) -> () in
                    
                    // here we don't use self (no retain cycle)
                    forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                    
                }
                
                popEndDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
                return false
        } else if textField == nilpeterProductTextField {
            performSegueWithIdentifier("nilpeterProduct", sender: self)
            return true
        } else if textField == otherProductTextField {
            performSegueWithIdentifier("otherProduct", sender: self)
            return true
        } else if textField == engineerTextField {
            performSegueWithIdentifier("engineer", sender: self)
            return true
        }
        return true
    }
    
    // MARK: - post method
    
    @IBAction func postToArm(sender: AnyObject) {
        
        // Showloading spinner
        self.showLoading()
        self.descriptionTextField.resignFirstResponder()
        
        // Parse information
        var dateString = ""
        var endDateString = ""
        var companyString = ""
        var jobString = ""
        var machineString = ""
        var combinedIdArray = ""
        var engineerArray = ""
        var descriptionString = ""
        let userIdString = ", \"user_id\": \"\(self.prefs.integerForKey("Userid"))\" "
        
        if let dateTime = dateTextField.text {
            dateString = "\"date\": \"\(dateTime)\" "
        }
        
        if let endDateTime = endDateTextField.text {
            endDateString = ", \"end_date\": \"\(endDateTime)\" "
        }
        
        if let companyName = companyTextField.text {
            companyString = ", \"company_name\": \"\(companyName)\" "
        }
        
        if let jobNumName = jobNumTextField.text {
            jobString = ", \"job_num\": \"\(jobNumName)\" "
        }
        
        if let machineNumName = machineTextField.text {
            machineString = ", \"machine_number\": \"\(machineNumName)\" "
        }
        
        if (self.prefs.stringForKey("Email") == "admin@nilpeter.com") {
            engineerArray = ", \"engineer_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds)) "
        } else {
            engineerArray = ", \"engineer_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds + [self.prefs.integerForKey("Userid")])) "
        }
        
        
        
        if let nilpeterProductId = product?.productPickerIdArray {
            if let thirdPartyProductId = product?.otherProductPickerIdArray {
                combinedIdArray = ", \"product_ids\": \(convertArrayIntToArratString(nilpeterProductId + thirdPartyProductId)) "
            } else {
                combinedIdArray = ", \"product_ids\": \(convertArrayIntToArratString(nilpeterProductId)) "
            }
        } else if let thirdPartyProductId = product?.otherProductPickerIdArray {
            combinedIdArray = ", \"product_ids\": \(convertArrayIntToArratString(thirdPartyProductId)) "
        }
        
        if let description = descriptionTextField.text {
            descriptionString = ", \"project\": \"\(description)\" "
        }
        
        let body = "{" + dateString + endDateString + companyString + jobString + machineString + combinedIdArray + engineerArray + descriptionString + userIdString + "}"
        
        print(body)

        // Send to the cloud
        
        let scheduleService = ScheduleService()
        scheduleService.postSchedule(body,postId: nil, postMethod: "POST") {
            status in
            if let returnMessage = status as String? {
                print(returnMessage)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.tabBarController?.selectedIndex = 0
                    self.cancelAllFields()
                    self.hideLoading()
                    self.showSubmitted()
                }
            }
        }
    }
    
    // MARK: - unwind company from company table view
    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
//        if segue.sourceViewController.isKindOfClass(SearchTableViewController) {
//            let searchController = segue.sourceViewController as! SearchTableViewController
//            if searchController.company?.parentCompany != nil {
//                companyTextField.text = searchController.company?.parentCompany
//        }
        
            
        if segue.sourceViewController.isKindOfClass(NilpeterProductTableViewController) {
            let nilpeterProductsController = segue.sourceViewController as! NilpeterProductTableViewController
            if let selectedProductArray = nilpeterProductsController.selectedProducts {
                selectedProductName = selectedProductArray // assign to segue pass back variable
                nilpeterProductTextField.text = selectedProductName.description
                
                self.product?.productPickerIdArray?.removeAll()
                for product in selectedProductArray {
                    if let id = self.product?.productDict![product] {
                        self.product?.productPickerIdArray?.append(id)
                    }
                }
                
            }
            
        } else if segue.sourceViewController.isKindOfClass(ThirdPartyProductTableViewController) {
            let otherProductsController = segue.sourceViewController as! ThirdPartyProductTableViewController
            if let selectedProductArray = otherProductsController.selectedProducts {
                selectedOtherProductName = selectedProductArray // assign to segue pass back variable
                otherProductTextField.text = selectedOtherProductName.description
                
                self.product?.otherProductPickerIdArray?.removeAll()
                for product in selectedProductArray {
                    if let id = self.product?.productDict![product] {
                        self.product?.otherProductPickerIdArray?.append(id)
                    }
                }
                
            }
        } else if segue.sourceViewController.isKindOfClass(EngineerViewController) {
            self.engineerTextField.text = Engineer.pickedEngineerNames.description
            print(Engineer.pickedEngineerIds)
            
        }
    }
    
    // MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nilpeterProduct" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! NilpeterProductTableViewController
            destination.selectedProducts = selectedProductName
            destination.product = self.product
        } else if segue.identifier == "otherProduct" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! ThirdPartyProductTableViewController
            destination.selectedProducts = selectedOtherProductName
            destination.product = self.product
        }
    }
    
    // MARK: - Helper functions
    
    func convertArrayIntToArratString(arrayInt: [Int]) -> [String] {
        var outArray = [String]()
        for i in arrayInt {
            outArray.append("\(i)")
        }
        return outArray
    }
    
    func hideLoading() {
        spinner.stopAnimating()
        loadingLabel.hidden = true
    }
    
    func showLoading() {
        spinner.startAnimating()
        loadingLabel.hidden = false
        hideSubmitted()
    }
    
    func showSubmitted() {
        updateText.hidden = false
    }
    
    func resetCompany() {
        self.companyTextField.text?.removeAll()
    }
    
    func hideSubmitted() {
        updateText.hidden = true
    }
    
    
    func resetProducts() {
        self.nilpeterProductTextField.text?.removeAll()
        self.otherProductTextField.text?.removeAll()
        self.product?.productPickerIdArray?.removeAll()
        self.product?.otherProductPickerIdArray?.removeAll()
        self.selectedProductName = [String]() // send back segue data
        self.selectedOtherProductName = [String]() // send back segue data
    }
    
    func resetEngineers() {
        Engineer.pickedEngineerNames = []
        Engineer.pickedEngineerIds = []
        self.engineerTextField.text?.removeAll()
    }
    
    func cancelAllFields() {
        
        self.dateTextField.text?.removeAll()
        self.endDateTextField.text?.removeAll()
        resetCompany()
        resetProducts()
        self.descriptionTextField.text?.removeAll()
        self.descriptionTextField.resignFirstResponder()
        self.endDateTextField.text?.removeAll()
        resetEngineers()
        self.jobNumTextField.text?.removeAll()
        self.machineTextField.text?.removeAll()
        hideSubmitted()
    }
    
    @IBAction func cancelSchedule(sender: AnyObject) {
        self.cancelAllFields()
    }
    
    
}


