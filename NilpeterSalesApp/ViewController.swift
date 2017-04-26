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
    
    var alreadyLoaded = false;
    
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
    var productTimer = Timer()
    
    // engineer
    @IBOutlet weak var engineerTextField: UITextField!
    @IBOutlet weak var loadingEngineerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingEngineerLabel: UILabel!
    
    var engineerTimer = Timer()
    
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
    var prefs: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User store
        // Check user session
        prefs = UserDefaults.standard
        if prefs.integer(forKey: "Session") == 0 {
            self.performSegue(withIdentifier: "showLogin", sender: self)
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
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.tabBarController?.tabBar.barTintColor = UIColor.red
        self.tabBarController?.tabBar.tintColor = UIColor.white
        
//        self.getProducts()
//        productTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updateProducts), userInfo: nil, repeats: true)
//        self.getEngineers()
//        engineerTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updateEngineers), userInfo: nil, repeats: true)
        
        // Submitting spinner
        loadingLabel = UILabel.init(frame: CGRect(x: self.view.frame.size.width - 75, y: 0, width: 80, height: 35))
        loadingLabel.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        loadingLabel.text = "Submitting..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.frame = CGRect(x: self.view.frame.size.width - 130, y: 0, width: 80, height: 35)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        self.hideLoading()
        
        updateText = UILabel.init(frame: CGRect(x: self.view.frame.size.width - 150, y: 0, width: 150, height: 35))
        updateText.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        updateText.text = "Succesfully submitted!"
        view.addSubview(updateText)
        hideSubmitted()
        
        welcome = UILabel.init(frame: CGRect(x: 10, y: 0, width: 175, height: 35))
        welcome.font = UIFont(name: "HelveticaNeue-Light", size: 14)
        if let email = self.prefs.string(forKey: "Email") {
            welcome.text = "Welcome \(email)"
        }
        view.addSubview(welcome)
        
        chargeStatus.setTitleColor(UIColor.blue, for: UIControlState())
        
        sendButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(self.prefs.integer(forKey: "Userid"))
        if let email = self.prefs.string(forKey: "Email") {
            welcome.text = "Welcome \(email)"
        }
        
        if (prefs.integer(forKey: "Session") == 1 && self.alreadyLoaded == false) {
            self.getProducts()
            productTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updateProducts), userInfo: nil, repeats: true)
            self.getEngineers()
            engineerTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updateEngineers), userInfo: nil, repeats: true)
            self.alreadyLoaded = true
        }

        
        downLoadJobNum(String(self.prefs.integer(forKey: "Userid")))
    }

    

    @IBAction func chargeButtonPressed(_ sender: AnyObject) {
        print("click")
        print(chargeStatusNum == 0)
        if chargeStatusNum == 0 {
            chargeStatus.setTitle("chargable", for: UIControlState())
            chargeStatusNum = 1
            chargeStatus.setTitleColor(UIColor.red, for: UIControlState())
        } else if chargeStatusNum == 1 {
            chargeStatus.setTitle("non-chargable", for: UIControlState())
            chargeStatusNum = 0
            chargeStatus.setTitleColor(UIColor.blue, for: UIControlState())
        }
    }
    
    // MARK: - UIPickerView Delegate
    
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    // MARK: - Get information from the cloud
    
    func showLoadProducts() {
        loadingNilpeterIndicator.startAnimating()
        loadingThirdIndicator.startAnimating()
        loadingNilpeterIndicator.isHidden = false
        loadingNilpeterProducts.isHidden = false
        loadingThirdIndicator.isHidden = false
        loadingThirdLabel.isHidden = false
        nilpeterProductTextField.isUserInteractionEnabled = false
        otherProductTextField.isUserInteractionEnabled = false
    }
    func hideLoadProducts() {
        loadingNilpeterIndicator.stopAnimating()
        loadingThirdIndicator.stopAnimating()
        loadingNilpeterIndicator.isHidden = true
        loadingThirdIndicator.isHidden = true
        loadingNilpeterProducts.isHidden = true
        loadingThirdLabel.isHidden = true
        nilpeterProductTextField.isUserInteractionEnabled = true
        otherProductTextField.isUserInteractionEnabled = true
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
                DispatchQueue.main.async {
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
        loadingEngineerIndicator.isHidden = false
        loadingEngineerLabel.isHidden = false
        engineerTextField.isUserInteractionEnabled = false
    }
    func hideLoadEngineers() {
        loadingEngineerIndicator.stopAnimating()
        loadingEngineerIndicator.isHidden = true
        loadingEngineerLabel.isHidden = true
        engineerTextField.isUserInteractionEnabled = true
    }
    
    func updateEngineers() {
        getEngineers()
        print("timer get engineers")
        
    }
    
    func downLoadJobNum(_ idString: String) {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules/auto_jobnum/", idString: idString) {
            newJobNums in
            DispatchQueue.main.async {
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
                DispatchQueue.main.async {
                    for engineer in engineerArray {
                        if let engineertName = engineer["email"] as? String {
                            if engineertName == "admin@nilpeter.com" {
//                                print("don't add admin")
                            } else if engineertName == "ios@nilpeter.com" {
//                                print("don't add ios")
                            } else if engineertName == self.prefs.string(forKey: "Email") {
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
                    self.sendButton.isEnabled = true
//                    print(Engineer.engineerArray)
                }
            }
        }
    }


    func addCompany(_ company: String) {
        companyTextField.text = company
        tableView.reloadData()
    }
    
    // MARK: - DatePicker popup
    
    func resign() {
        dateTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField == descriptionTextField || textField == machineTextField || textField == jobNumTextField || textField == companyTextField {
//            textField.resignFirstResponder()
//            return true
//        }
        textField.resignFirstResponder()
        return true
        
    }
    
    // MARK: - Text Field delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if (textField === dateTextField) {
            resign()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy HH:mm"
            let initDate : Date? = formatter.date(from: dateTextField.text!)
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
    
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                
            }
            
            popDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            return false
        } else if (textField === endDateTextField) {
                resign()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm"
                let initDate : Date? = formatter.date(from: endDateTextField.text!)
                let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                    
                    // here we don't use self (no retain cycle)
                    forTextField.text = (newDate.ToDateMediumString() ?? "?") as String
                    
                }
                
                popEndDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
                return false
        } else if textField == nilpeterProductTextField {
            performSegue(withIdentifier: "nilpeterProduct", sender: self)
            return true
        } else if textField == otherProductTextField {
            performSegue(withIdentifier: "otherProduct", sender: self)
            return true
        } else if textField == engineerTextField {
            performSegue(withIdentifier: "engineer", sender: self)
            return true
        }
        return true
    }
    
    // MARK: - post method
    
    @IBAction func postToArm(_ sender: AnyObject) {
        
        if dateTextField.text == "" || endDateTextField.text == "" || companyTextField.text == "" || descriptionTextField.text == "" || companyTextField.text == "" || jobNumTextField.text == "" {
            let alert = UIAlertController(title: "Alert", message: "Please make sure date, company, job , and description fields are not empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
        
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
            let userIdString = ", \"user_id\": \"\(self.prefs.integer(forKey: "Userid"))\" "
            
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
            
            if (self.prefs.string(forKey: "Email") == "admin@nilpeter.com") {
                engineerArray = ", \"engineer_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds)) "
            } else {
                engineerArray = ", \"engineer_ids\": \(convertArrayIntToArratString(Engineer.pickedEngineerIds + [self.prefs.integer(forKey: "Userid")])) "
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
            
            let chargeStatusString = ", \"chargable\": \"\(chargeStatusNum)\" "
            
            let body = "{" + dateString + endDateString + companyString + jobString + machineString + combinedIdArray + engineerArray + descriptionString + chargeStatusString + userIdString + "}"
            
            print(body)

            // Send to the cloud
            

            let scheduleService = ScheduleService()
            print(User.headingBaseURL)
            scheduleService.postSchedule(body,postId: nil, postMethod: "POST") {
                status in
                if let returnMessage = status as String? {
                    print(returnMessage)
                    
                    DispatchQueue.main.async {
                        
                        self.tabBarController?.selectedIndex = 0
                        self.cancelAllFields()
                        self.hideLoading()
                        self.showSubmitted()
                    }
                }
            }
          
        }
        
    }
    
    // MARK: - unwind company from company table view
    @IBAction func unwindFromModalViewController(_ segue: UIStoryboardSegue) {
//        if segue.sourceViewController.isKindOfClass(SearchTableViewController) {
//            let searchController = segue.sourceViewController as! SearchTableViewController
//            if searchController.company?.parentCompany != nil {
//                companyTextField.text = searchController.company?.parentCompany
//        }
        
            
        if segue.source.isKind(of: NilpeterProductTableViewController.self) {
            let nilpeterProductsController = segue.source as! NilpeterProductTableViewController
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
            
        } else if segue.source.isKind(of: ThirdPartyProductTableViewController.self) {
            let otherProductsController = segue.source as! ThirdPartyProductTableViewController
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
        } else if segue.source.isKind(of: EngineerViewController.self) {
            self.engineerTextField.text = Engineer.pickedEngineerNames.description
            print(Engineer.pickedEngineerIds)
            
        }
    }
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nilpeterProduct" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! NilpeterProductTableViewController
            destination.selectedProducts = selectedProductName
            destination.product = self.product
        } else if segue.identifier == "otherProduct" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! ThirdPartyProductTableViewController
            destination.selectedProducts = selectedOtherProductName
            destination.product = self.product
        }
    }
    
    // MARK: - Helper functions
    
    func convertArrayIntToArratString(_ arrayInt: [Int]) -> [String] {
        var outArray = [String]()
        for i in arrayInt {
            outArray.append("\(i)")
        }
        return outArray
    }
    
    func hideLoading() {
        spinner.stopAnimating()
        loadingLabel.isHidden = true
    }
    
    func showLoading() {
        spinner.startAnimating()
        loadingLabel.isHidden = false
        hideSubmitted()
    }
    
    func showSubmitted() {
        updateText.isHidden = false
    }
    
    func resetCompany() {
        self.companyTextField.text?.removeAll()
    }
    
    func hideSubmitted() {
        updateText.isHidden = true
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
        chargeStatus.setTitle("non-chargable", for: UIControlState())
        chargeStatusNum = 0
        chargeStatus.setTitleColor(UIColor.blue, for: UIControlState())
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
    
    @IBAction func cancelSchedule(_ sender: AnyObject) {
        self.cancelAllFields()
    }
    
    
}


