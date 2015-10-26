//
//  LoginViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 10/5/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var verifyingTextField: UILabel!
    @IBOutlet weak var verifyingLoading: UIActivityIndicatorView!
    
    var user: User?
    var prefs: NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem = nil
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        self.tabBarController?.tabBar.hidden = true
        self.navigationItem.title = "Login"
        self.email.delegate = self
        self.password.delegate = self
        
        self.verifyingHide()
        
        // Store and password
        prefs = NSUserDefaults.standardUserDefaults()
    }
    
    func validateUser() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("user") {
            user in
            dispatch_async(dispatch_get_main_queue()) {
                if let validUser = user {
                    // Check to see if user exist, if so will return
                    // [["message": Successfully login, "user_id": userid]]
                    if let userId = validUser.first!["user_id"] as? Int {
                        User.userId = userId
                        User.session = 1
                        
//                        self.prefs.setValue(self.email.text, forKey: "Email")
//                        self.prefs.setValue(self.password.text, forKey: "Password")
                        self.prefs.setValue(userId, forKey: "Userid")
                        self.prefs.setValue(1, forKey: "Session")
                        
                        self.tabBarController?.tabBar.hidden = false
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        self.verifyingHide()
                        
                    }
                    else {
                        print("cannot find userid")
                    }
                    
                } else {
                    print("invalid user or password")
                    self.verifyingHide()
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.showAlert()
                    
                }
            }
        }
    }
    
    func showAlert() {
        let alertView = UIAlertController(title: "Invalid Username or Password", message: "Please reenter username and password again", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func verifyingShow() {
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        self.login.enabled = false
        self.verifyingTextField.hidden = false
        self.verifyingLoading.hidden = false
        self.verifyingLoading.startAnimating()
    }
    
    func verifyingHide() {
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        self.login.enabled = true
        self.verifyingTextField.hidden = true
        self.verifyingLoading.hidden = true
        self.verifyingLoading.stopAnimating()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func login(sender: AnyObject) {
        User.email = self.email.text!
        User.password = self.password.text!
        self.verifyingShow()
        validateUser()
    }
}
