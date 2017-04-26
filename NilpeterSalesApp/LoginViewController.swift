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
    @IBOutlet weak var serverName: UITextField!
    
    var user: User?
    var prefs: UserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = true
        self.navigationItem.backBarButtonItem = nil
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "Login"
        self.email.delegate = self
        self.password.delegate = self
        
        self.verifyingHide()
        
        // Store and password
        prefs = UserDefaults.standard
    }
    
    func validateUser() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("user", idString: nil) {
            user in
            DispatchQueue.main.async {
                if let validUser = user {
                    // Check to see if user exist, if so will return
                    // [["message": Successfully login, "user_id": userid]]
                    if let userId = validUser.first!["user_id"] as? Int {
                        User.userId = userId
    
//                        self.prefs.setValue(self.email.text, forKey: "Email")
//                        self.prefs.setValue(self.password.text, forKey: "Password")
                        self.prefs.setValue(userId, forKey: "Userid")
                        self.prefs.setValue(User.email, forKey: "Email")
                        self.prefs.setValue(1, forKey: "Session")
                        self.tabBarController?.tabBar.isHidden = false
                        self.navigationController?.popToRootViewController(animated: true)
                        self.verifyingHide()
                        
                    }
                    else {
                        print("cannot find userid")
                    }
                    
                } else {
                    print("invalid user or password")
                    self.verifyingHide()
                    self.dismiss(animated: true, completion: nil)
                    self.showAlert()
                    
                }
            }
        }
    }
    
    func showAlert() {
        let alertView = UIAlertController(title: "Invalid Username or Password", message: "Please reenter username and password again", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func verifyingShow() {
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        self.login.isEnabled = false
        self.verifyingTextField.isHidden = false
        self.verifyingLoading.isHidden = false
        self.verifyingLoading.startAnimating()
    }
    
    func verifyingHide() {
        self.email.resignFirstResponder()
        self.password.resignFirstResponder()
        self.login.isEnabled = true
        self.verifyingTextField.isHidden = true
        self.verifyingLoading.isHidden = true
        self.verifyingLoading.stopAnimating()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func login(_ sender: AnyObject) {
        User.email = self.email.text!
        User.password = self.password.text!
        self.prefs.setValue(self.serverName.text, forKey: "ServerName")
        User.headingBaseURL = prefs.string(forKey: "ServerName")! + "/"
        self.verifyingShow()
        validateUser()
    }
}
