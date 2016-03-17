//
//  TableViewEditController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 2/5/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class TableViewEditController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIWebViewDelegate {
    
    
    var id: Int?
    
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
    
    @IBOutlet weak var chargeStatus: UIButton!
    var chargeStatusNum: Int = 0
    
    let webView: UIWebView = UIWebView()
    
    // Spinner
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    var updateText: UILabel!
    var welcome: UILabel!
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
   
    
    // User store
    var prefs: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize company and location models
        product = Product()
        
        print("des \(id)")
        
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
        companyTextField.delegate = self
        jobNumTextField.delegate = self
        machineTextField.delegate = self
        
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
        updateText.text = "Succesfully editted!"
        view.addSubview(updateText)
        hideSubmitted()
        
        welcome = UILabel.init(frame: CGRectMake(10, 0, 175, 35))
        welcome.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        if let email = self.prefs.stringForKey("Email") {
            welcome.text = "Welcome \(email)"
        }
        view.addSubview(welcome)
        
        chargeStatus.setTitleColor(UIColor.blueColor(), forState: .Normal)
        
        sendButton.enabled = false
        
        removeSchedules()
        
        
        if id != nil {
            getSchedule(String(id!))
        }
        
        
    }
    
    func removeSchedules() {
        Schedules.nilpeterProducts.removeAll()
        Schedules.thirdProducts.removeAll()
        Schedules.pickedThirdProductIds.removeAll()
        Schedules.pickedNilpeterProductIds.removeAll()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = self.prefs.stringForKey("Email") {
            welcome.text = "Welcome \(email)"
        }
        
    }
    
    @IBAction func chargeButtonPressed(sender: AnyObject) {
        print("click")
        print(chargeStatusNum == 0)
        if chargeStatusNum == 0 {
            chargeStatus.setTitle("chargable", forState: .Normal)
            chargeStatusNum = 1
            chargeStatus.setTitleColor(UIColor.redColor(), forState: .Normal)
        } else if chargeStatusNum == 1 {
            chargeStatus.setTitle("non-chargable", forState: .Normal)
            chargeStatusNum = 0
            chargeStatus.setTitleColor(UIColor.blueColor(), forState: .Normal)
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
    
    
    func getSchedule(idStrng: String) {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules/", idString: idStrng) {
            schedule in
            
            if let validSchedule = schedule {
                dispatch_async(dispatch_get_main_queue()) {
//                    print(validSchedule)
                    if let companyName = validSchedule.first!["company_name"] {
                        self.companyTextField.text = companyName as? String
                    }
                    if let date = validSchedule.first!["date"] {
                        self.dateTextField.text = date as? String
                    }
                    if let endDate = validSchedule.first!["end_date"] {
                        self.endDateTextField.text = endDate as? String
                    }
                    if let jobNum = validSchedule.first!["job_num"] {
                        self.jobNumTextField.text = jobNum as? String
                    }
                    if let machineNum = validSchedule.first!["machine_number"] {
                        self.machineTextField.text = machineNum as? String
                    }
                    if let proj = validSchedule.first!["project"] {
                        self.descriptionTextField.text = proj as? String
                    }
                    
                    if let chargable = validSchedule.first!["chargable"] as? Int {
                        if chargable == 1 {
                            self.chargeStatus.setTitle("chargable", forState: .Normal)
                            self.chargeStatus.setTitleColor(UIColor.redColor(), forState: .Normal)
                            self.chargeStatusNum = 1
                        }
                    }
                    
                    self.getNilpeters(String(self.id!))
                    self.getThird(String(self.id!))
                    self.getSelectedEngineer(String(self.id!))
//                    if let scheduleId = validSchedule.first!["id"] as? String {
//                        Schedules.scheduleId = scheduleId
//                       
//                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getNilpeters(idString: String) {
        showLoadProducts()
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules/find_nilpeters/", idString: idString) {
            schedule in
            
            if let validSchedule = schedule {
                dispatch_async(dispatch_get_main_queue()) {
                    for product in validSchedule {
                        if let nilpeterProduct = product["name"] as? String {
                            Schedules.nilpeterProducts.append(nilpeterProduct);
                            if let productId = product["id"] as? Int {
//                                Schedules.productDicts[nilpeterProduct] = productId
                                Schedules.pickedNilpeterProductIds.append(productId)
                            }
                        }
                    }
                    self.nilpeterProductTextField.text = Schedules.nilpeterProducts.debugDescription
                    self.hideLoadProducts()
//                    print(Schedules.pickedNilpeterProductIds)
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    func getThird(idString: String) {
        
        showLoadProducts()
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules/find_third/", idString: idString) {
            schedule in
            
            if let validSchedule = schedule {
                dispatch_async(dispatch_get_main_queue()) {
                    for product in validSchedule {
                        if let thirdProduct = product["name"] as? String {
                            Schedules.thirdProducts.append(thirdProduct);
                            if let productId = product["id"] as? Int {
//                                Schedules.productDicts[thirdProduct] = productId
                                Schedules.pickedThirdProductIds.append(productId)
                            }
                        }
                    }
                    self.otherProductTextField.text = Schedules.thirdProducts.debugDescription
                    self.hideLoadProducts()
                    print(Schedules.pickedThirdProductIds)
                    self.tableView.reloadData()
                }
            }
        }

        
    }
    
    func getSelectedEngineer(idString: String) {
        Engineer.pickedEngineerIds.removeAll()
        Engineer.pickedEngineerNames.removeAll()
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules/find_users/", idString: idString) {
            schedule in
            
            if let validSchedule = schedule {
                dispatch_async(dispatch_get_main_queue()) {
                    for engineers in validSchedule {
                        if let engineerName = engineers["email"] as? String {
                            Engineer.pickedEngineerNames.append(engineerName)
                            if let engineerId = engineers["id"] as? Int {
                                //                                Schedules.productDicts[thirdProduct] = productId
                                Engineer.pickedEngineerIds.append(engineerId)
                            }
                        }
                    }
//                    print(Engineer.pickedEngineerNames.debugDescription)
//                    print(Engineer.pickedEngineerIds.debugDescription)
                    self.engineerTextField.text = Engineer.pickedEngineerNames.debugDescription
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    func getEngineers() {
        showLoadProducts()
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
//        if textField == descriptionTextField {
//            textField.resignFirstResponder()
//            return true
//        }
        textField.resignFirstResponder()
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
            performSegueWithIdentifier("editNilpeterProduct", sender: self)
            return true
        } else if textField == otherProductTextField {
            performSegueWithIdentifier("editOtherProduct", sender: self)
            return true
        } else if textField == engineerTextField {
            performSegueWithIdentifier("editEngineer", sender: self)
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
        
        engineerArray = ", \"user_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds)) "
        
//        if (self.prefs.stringForKey("Email") == "admin@nilpeter.com") {
//            engineerArray = ", \"engineer_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds)) "
//        } else {
//            engineerArray = ", \"engineer_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds + [self.prefs.integerForKey("Userid")])) "
//        }
        
        combinedIdArray = ", \"product_ids\": " + (convertArrayIntToArratString(Schedules.pickedNilpeterProductIds) + convertArrayIntToArratString(Schedules.pickedThirdProductIds)).debugDescription
        
//        if let nilpeterProductId = product?.productPickerIdArray {
//            if let thirdPartyProductId = product?.otherProductPickerIdArray {
//                combinedIdArray = ", \"product_ids\": \(convertArrayIntToArratString(nilpeterProductId + thirdPartyProductId)) "
//            } else {
//                combinedIdArray = ", \"product_ids\": \(convertArrayIntToArratString(nilpeterProductId)) "
//            }
//        } else if let thirdPartyProductId = product?.otherProductPickerIdArray {
//            combinedIdArray = ", \"product_ids\": \(convertArrayIntToArratString(thirdPartyProductId)) "
//        }
        
        
        
        if let description = descriptionTextField.text {
            descriptionString = ", \"project\": \"\(description)\" "
        }
        
        let chargeStatusString = ", \"chargable\": \"\(chargeStatusNum)\" "
        
        let body = "{" + dateString + endDateString + companyString + jobString + machineString + combinedIdArray + engineerArray + descriptionString + chargeStatusString + userIdString + "}"
        
        print(body)
        
        // Send to the cloud
        
        let scheduleService = ScheduleService()
        scheduleService.postSchedule(body,postId: String(self.id!), postMethod: "PUT") {
            status in
            if let returnMessage = status as String? {
                print(returnMessage)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    // self.tabBarController?.selectedIndex = 2
                    self.cancelAllFields()
                    self.hideLoading()
                    self.showSubmitted()
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        }
    }
    
    // MARK: - unwind company from company table view
    @IBAction func unwindFromModalEditViewController(segue: UIStoryboardSegue) {
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
                
                Schedules.nilpeterProducts.removeAll()
                Schedules.pickedNilpeterProductIds.removeAll()
                Schedules.nilpeterProducts = selectedProductName
                
                for product in selectedProductArray {
                    if let id = self.product?.productDict![product] {
                        self.product?.productPickerIdArray?.append(id)
                        Schedules.pickedNilpeterProductIds.append(id)
                    }
                    
                }
//                print(Schedules.pickedNilpeterProductIds)
                
                
            }
            
        } else if segue.sourceViewController.isKindOfClass(ThirdPartyProductTableViewController) {
            let otherProductsController = segue.sourceViewController as! ThirdPartyProductTableViewController
            if let selectedProductArray = otherProductsController.selectedProducts {
                selectedOtherProductName = selectedProductArray // assign to segue pass back variable
                otherProductTextField.text = selectedOtherProductName.description
                
                self.product?.otherProductPickerIdArray?.removeAll()
                Schedules.thirdProducts.removeAll()
                Schedules.pickedThirdProductIds.removeAll()
                Schedules.thirdProducts = selectedOtherProductName
                
                for product in selectedProductArray {
                    if let id = self.product?.productDict![product] {
                        self.product?.otherProductPickerIdArray?.append(id)
                        Schedules.pickedThirdProductIds.append(id)
                    }
                }
                print(Schedules.pickedThirdProductIds)
            }
        } else if segue.sourceViewController.isKindOfClass(EngineerViewController) {
            self.engineerTextField.text = Engineer.pickedEngineerNames.description
            print(Engineer.pickedEngineerIds)
            
        }
    }
    
    // MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editNilpeterProduct" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! NilpeterProductTableViewController
            destination.selectedProducts = Schedules.nilpeterProducts
            destination.product = self.product
            destination.fromEditPage = true
        } else if segue.identifier == "editOtherProduct" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! ThirdPartyProductTableViewController
            destination.selectedProducts = Schedules.thirdProducts
            destination.product = self.product
            destination.fromEditPage = true
        } else if segue.identifier == "editEngineer" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! EngineerViewController
            destination.fromEditPage = true
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
    
    func clearChargable() {
        chargeStatus.setTitle("non-chargable", forState: .Normal)
        chargeStatusNum = 0
        chargeStatus.setTitleColor(UIColor.blueColor(), forState: .Normal)
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
        clearChargable()
    }
    
    @IBAction func cancelSchedule(sender: AnyObject) {
        self.cancelAllFields()
    }

    
    @IBAction func dismissViewController(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
