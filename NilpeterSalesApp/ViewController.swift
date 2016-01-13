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
    var company: Company?
    @IBOutlet weak var companyTextField: UITextField!
    
    // products
    var product: Product?
    @IBOutlet var nilpeterProductTextField: UITextField!
    @IBOutlet var otherProductTextField: UITextField!
    var selectedProductName = [String]() // send back segue data
    var selectedOtherProductName = [String]() // send back segue data
    
    // Description
    @IBOutlet var descriptionTextField: UITextField!
    let webView: UIWebView = UIWebView()
    
    // Spinner
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    // User store
    var prefs: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User store
        // Check user session
        prefs = NSUserDefaults.standardUserDefaults()
//        if prefs.integerForKey("Session") == 0 {
//            self.performSegueWithIdentifier("showLogin", sender: self)
//        }
       
        // disable table view selection
        self.tableView.allowsSelection = false
        
        // initialize company and location models
        company = Company()
        product = Product()
        
        // location pickerview
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        popEndDatePicker = PopDatePicker(forTextField: endDateTextField)
        dateTextField.delegate = self
        endDateTextField.delegate = self
        companyTextField.delegate = self
        nilpeterProductTextField.delegate = self
        otherProductTextField.delegate = self
        descriptionTextField.delegate = self
        
        // UI Design
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.tabBarController?.tabBar.barTintColor = UIColor.redColor()
        self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        
        self.getProducts()
        self.getComapnies()
        
        // Submitting spinner
        loadingLabel = UILabel.init(frame: CGRectMake(self.view.frame.size.width - 75, 0, 80, 35))
        loadingLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 14)
        loadingLabel.text = "Submitting..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.size.width - 130, 0, 80, 35)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        self.hideLoading()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if company == nil {
            self.getProducts()
            self.getComapnies()
            self.showLoading()
        }
    }
    
    // MARK: - UIPickerView Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    // MARK: - Get information from the cloud
   
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
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            if let comArray = companies {
                dispatch_async(dispatch_get_main_queue()) {
                    let comArrayObj = Company(dictArray: comArray)
                    self.company?.companies = comArrayObj.companyArray!
                    self.company?.parentCompanyDict = comArrayObj.companyDict
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
        } else if textField == companyTextField {
            performSegueWithIdentifier("toATable", sender: self)
            return true
        } else if textField == nilpeterProductTextField {
            performSegueWithIdentifier("nilpeterProduct", sender: self)
            return true
        } else if textField == otherProductTextField {
            performSegueWithIdentifier("otherProduct", sender: self)
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
        var companyString = ""
        var combinedIdArray = ""
        var descriptionString = ""
        let userIdString = ", \"user_id\": \"\(self.prefs.integerForKey("Userid"))\" "
        
        if let dateTime = dateTextField.text {
            dateString = "\"date\": \"\(dateTime)\" "
        }
        if let companyId = company?.companyId {
            companyString = ", \"company_id\": \"\(companyId)\" "
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
        
        let body = "{" + dateString + companyString + combinedIdArray + descriptionString + userIdString + "}"

        // Send to the cloud
        
        
        
        let scheduleService = ScheduleService()
        scheduleService.postSchedule(body) {
            status in
            if let returnMessage = status as String? {
                print(returnMessage)
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.tabBarController?.selectedIndex = 1
                    self.cancelAllFields()
                    self.hideLoading()
                    
                }
            }
        }
    }
    
    // MARK: - unwind company from company table view
    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if segue.sourceViewController.isKindOfClass(SearchTableViewController) {
            let searchController = segue.sourceViewController as! SearchTableViewController
            if searchController.company?.parentCompany != nil {
                companyTextField.text = searchController.company?.parentCompany
                company?.companyId = searchController.company?.parentCompanyId
        }
            
            
        } else if segue.sourceViewController.isKindOfClass(NilpeterProductTableViewController) {
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
        } else if segue.identifier == "toATable" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! SearchTableViewController
            destination.company = self.company
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
    }
    
    func resetCompany() {
        self.company = Company()
        self.companyTextField.text?.removeAll()
        self.getComapnies()
    }
    
    func resetProducts() {
        self.nilpeterProductTextField.text?.removeAll()
        self.otherProductTextField.text?.removeAll()
        self.product?.productPickerIdArray?.removeAll()
        self.product?.otherProductPickerIdArray?.removeAll()
        self.selectedProductName = [String]() // send back segue data
        self.selectedOtherProductName = [String]() // send back segue data
    }
    
    func cancelAllFields() {
        self.dateTextField.text?.removeAll()
        resetCompany()
        resetProducts()
        self.descriptionTextField.text?.removeAll()
        self.descriptionTextField.resignFirstResponder()
    }
    
    @IBAction func cancelSchedule(sender: AnyObject) {
        self.cancelAllFields()
    }
    
    
}


