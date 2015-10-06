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
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.title = "Login"
        self.tabBarController?.tabBar.hidden = true
        
        self.email.delegate = self
        self.password.delegate = self
    }
    
    func validateUser() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("user") {
            user in
            if let validUser = user {
                dispatch_async(dispatch_get_main_queue()) {
                    if let userId = validUser.first!["user_id"] as? Int {
                        User.userId = userId
                        User.session = 1
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    else {
                        print("not valid")
                    }
                }
            } else {
                print("invalid")
                self.dismissViewControllerAnimated(true, completion: nil)
                let alertView = UIAlertController(title: "Invalid Username or Password", message: "Please reenter username and password again", preferredStyle: .Alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func login(sender: AnyObject) {
        User.email = self.email.text!
        User.password = self.password.text!
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        validateUser()
    }
}
