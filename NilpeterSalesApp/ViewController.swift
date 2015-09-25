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
    var selectedProductName = []

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
        
        getProducts()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationPickerView.delegate = self
        locationTextField.inputView = locationPickerView
    }
    
    // MARK: - uipicker view
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return (product?.nilpeterProductArray?.count)!
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.resignFirstResponder()
        
        if pickerView == locationPickerView {
            // set location name
            self.locationTextField.text = (location?.locationArray)![row]
            // set loation id
            self.location?.pickerLocationId = self.location?.locationDict![self.locationTextField.text!]
            locationTextField.resignFirstResponder()
        }
        
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
                        self.location?.pickerLocationId = self.location?.locationDict![locationArray.first!]
                    }
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
            if searchController.company?.parentCompany != nil {
                companyTextField.text = searchController.company?.parentCompany
                company?.companyId = searchController.company?.parentCompanyId
                getLocations((company?.companyId)!)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nilpeterProduct" {
            print("out selected prod name \(selectedProductName)")
            let nav = segue.destinationViewController as! UINavigationController
            let destination = nav.topViewController as! NilpeterProductTableViewController
            destination.selectedProducts = selectedProductName as? [String]
        }
        
        
        
    }
    
    @IBAction func unwindFromNilpeterProducts(segue: UIStoryboardSegue) {
        if segue.sourceViewController.isKindOfClass(NilpeterProductTableViewController) {
            let nilpeterProductsController = segue.sourceViewController as! NilpeterProductTableViewController
            if let selectedProductArray = nilpeterProductsController.selectedProducts {
                selectedProductName = selectedProductArray
                nilpeterProductTextField.text = selectedProductName.description
                print("in selected prod name \(selectedProductName)")
                self.product?.productPickerIdArray?.removeAll()
                for product in selectedProductArray {
                    let id = self.product?.productDict![product]
                    self.product?.productPickerIdArray?.append(id!)
                }
                print(self.product?.productPickerIdArray)
            }
        }
    }
    
    
    
}


