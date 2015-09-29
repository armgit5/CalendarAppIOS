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
    var allDayStatus = 0
    var popDatePicker : PopDatePicker?
    
    // search bar
    var company: Company?
    @IBOutlet weak var companyTextField: UITextField!
    
    // location picker view
    let locationPickerView = UIPickerView()
    var location: Location?
    @IBOutlet var locationTextField: UITextField!
    
    // products
    var product: Product?
    @IBOutlet var nilpeterProductTextField: UITextField!
    @IBOutlet var otherProductTextField: UITextField!
    var selectedProductName = [String]() // send back segue data
    var selectedOtherProductName = [String]() // send back segue data
    @IBOutlet var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable table view selection
        self.tableView.allowsSelection = false
        
        // initialize company and location models
        company = Company()
        location = Location()
        product = Product()
        
        // location pickerview
        popDatePicker = PopDatePicker(forTextField: dateTextField)
        dateTextField.delegate = self
        companyTextField.delegate = self
        nilpeterProductTextField.delegate = self
        otherProductTextField.delegate = self
        
        self.getProducts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if location?.locationArray != nil {
            locationPickerView.delegate = self
            locationTextField.inputView = locationPickerView
        }
        
    }
    
    // MARK: - uipicker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return (location?.locationArray!.count)!
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return location?.locationArray![row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.resignFirstResponder()
        
        
        // set location name
        self.locationTextField.text = (location?.locationArray)![row]
        // set loation id
        self.location?.pickerLocationId = self.location?.locationDict![self.locationTextField.text!]
        locationTextField.resignFirstResponder()
        
        
    }
    

    // MARK: - Get locations
    
    func getLocations(companyId: Int) {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("locations") {
            locations in
            if let locationArray = locations {
                dispatch_async(dispatch_get_main_queue()) {
                    let locationArrayObj = Location(dictArray: locationArray, companyId: companyId)
                    self.location?.locationArray = locationArrayObj.locationArray
                    self.location?.locationDict = locationArrayObj.locationDict
                    // check if location array exist, then set first location name and id
                    if let locationArray = self.location?.locationArray {
                        self.locationTextField.text = locationArray.first
                        if let firstLoc = locationArray.first {
                            self.location?.pickerLocationId = self.location?.locationDict![firstLoc]
                        } else {
                            self.location?.locationArray = nil
                            self.location?.pickerLocationId = nil
                            self.locationPickerView.delegate = nil
                            self.locationTextField.inputView = nil
                        }
                    }
                    
                    print(self.location?.pickerLocationId)
                }
            }
            
        }
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
                    self.tableView.reloadData()
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
        } else if textField == nilpeterProductTextField {
            performSegueWithIdentifier("nilpeterProduct", sender: self)
            return true
        } else if textField == otherProductTextField {
            performSegueWithIdentifier("otherProduct", sender: self)
        }
        return true
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
    
    func convertArrayIntToArratString(arrayInt: [Int]) -> [String] {
        var outArray = [String]()
        for i in arrayInt {
            outArray.append("\(i)")
        }
        return outArray
    }
    
    @IBAction func postToArm(sender: AnyObject) {
        
        print(dateTextField.text)
        print(allDayStatus)
        print(company?.companyId)
        print(location?.pickerLocationId)
        print(product?.productPickerIdArray)
        print(product?.otherProductPickerIdArray)
        print(descriptionTextField.text)
        
        
        var dateString = ""
        let allDayString = ", \"all_day\": \"\(allDayStatus)\" "
        var companyString = ""
        var locationIdString = ""
        var combinedIdArray = ""
        var descriptionString = ""
        let userIdString = ", \"user_id\": \"\(1)\" "
        
        if let dateTime = dateTextField.text {
            dateString = "\"date\": \"\(dateTime)\" "
        }
        
        if let companyId = company?.companyId {
            companyString = ", \"company_id\": \"\(companyId)\" "
        }
        
        if let locationId = location?.pickerLocationId {
            locationIdString = ", \"location_id\": \"\(locationId)\" "
        }
    
        
        if let nilpeterProductId = product?.productPickerIdArray {
            if let thirdPartyProductId = product?.otherProductPickerIdArray {
                combinedIdArray = ", \"products\": \(convertArrayIntToArratString(nilpeterProductId + thirdPartyProductId)) "
            } else {
                combinedIdArray = ", \"products\": \(convertArrayIntToArratString(nilpeterProductId)) "
            }
        } else if let thirdPartyProductId = product?.otherProductPickerIdArray {
            combinedIdArray = ", \"products\": \(convertArrayIntToArratString(thirdPartyProductId)) "
        }
        
        if let description = descriptionTextField.text {
            descriptionString = ", \"project\": \"\(description)\" "
        }
        
        let body = "{" + dateString + allDayString + companyString + locationIdString + combinedIdArray + descriptionString + userIdString + "}"
        
        print(body)
        
//        let scheduleService = ScheduleService()
//        
//        scheduleService.postSchedule(body) {
//            status in
//            if let returnMessage = status as String? {
//                print(returnMessage, terminator: "")
//            }
//        }
    }
    
    // MARK: - unwind company from company table view
    
    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if segue.sourceViewController.isKindOfClass(SearchTableViewController) {
            let searchController = segue.sourceViewController as! SearchTableViewController
            if searchController.company?.parentCompany != nil {
                companyTextField.text = searchController.company?.parentCompany
                company?.companyId = searchController.company?.parentCompanyId
                getLocations((company?.companyId)!)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nilpeterProduct" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! NilpeterProductTableViewController
            destination.selectedProducts = selectedProductName
        } else if segue.identifier == "otherProduct" {
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! ThirdPartyProductTableViewController
            destination.selectedProducts = selectedOtherProductName
        }
        
    }
    
}


