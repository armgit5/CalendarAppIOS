//
//  LoginViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 10/5/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.title = "Login"
    
    }
    
    
    func validateUser() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("user") {
            user in
            if let validUser = user {
                dispatch_async(dispatch_get_main_queue()) {
                    if let userId = validUser.first!["user_id"] as? Int {
                        User.userId = userId
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                    else {
                        print("not valid")
                    }
                }
            } else {
                print("invalid")
            }
            
        }
    }

    @IBAction func login(sender: AnyObject) {
//        User.email = self.email.text
//        User.password = self.password.text
        
        validateUser()
        // self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
