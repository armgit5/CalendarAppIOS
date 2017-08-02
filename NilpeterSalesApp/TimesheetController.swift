//
//  TimesheetController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 8/5/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class TimesheetController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBOutlet weak var nilpeterButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    @IBOutlet weak var nilpeterEraser: UIButton!
    @IBOutlet weak var customerEraser: UIButton!
    
    var prefs: UserDefaults!
    var webScript: String!
    
    var id: String!
    var createEdit: String!
    
    var created = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.prefs = UserDefaults.standard
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        Timesheet.hasTyped = false
        Timesheet.customerSignature = ""
        Timesheet.nilpeterSignature = ""
        
        print("view did load")
        print(createEdit == "/iostimesheet/")
        if createEdit == "/iostimesheet/" {
            nilpeterButton.isHidden = true
            nilpeterEraser.isHidden = true
            customerButton.isHidden = true
            customerEraser.isHidden = true
            submitButton.title = "Create"
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = URL(string: User.headingBaseURL + "/ioscalendar" + createEdit + id)
        print(url!)
        
        let request = URLRequest(url: url!)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(request)
        
        print("view will appear")
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        print("typing")
        Timesheet.hasTyped = true
    }

    func alert(_ sig: String) {
        let alert = UIAlertController(title: "Alert", message: "Please press no to go back and save the changes, press yes go to cotinue without saving (YOUR CHANGES WILL BE LOST WITHOUT SAVING).", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil)
        let cancelAction =  UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: {
            UIAlertAction in
            
            if sig == "back" {
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            if sig == "nilSig" {
                self.performSegue(withIdentifier: "showSignature", sender: "nilpeterSignature")
            }
            
            if sig == "cusSig" {
                self.performSegue(withIdentifier: "showSignature", sender: "customerSignature")
            }
            
            if sig == "fromCreate" {
                
            }
            
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertFromCreate(_ sig: String) {
        let alert = UIAlertController(title: "Alert", message: "Timesheet is being created. Please wait...", preferredStyle: UIAlertControllerStyle.alert)

//        let okAction =  UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
//            UIAlertAction in
//            
//            if sig == "fromCreate" {
//                self.navigationController?.popToRootViewController(animated: true)
//            }
//            
//            
//        })
        
//        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
//            alert.dismiss(animated: true, completion: nil)
            if sig == "fromCreate" {
                alert.dismiss(animated: true, completion: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }

    
    @IBAction func nilpeterSignature(_ sender: AnyObject) {
        
        if (!Timesheet.hasTyped) {
            performSegue(withIdentifier: "showSignature", sender: "nilpeterSignature")
        } else {
            alert("nilSig")
        }
        
    }
    
    @IBAction func customerSignature(_ sender: AnyObject) {
        if (!Timesheet.hasTyped) {
            performSegue(withIdentifier: "showSignature", sender: "customerSignature")
        } else {
            alert("cusSig")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignature" {
            if sender as! String == "nilpeterSignature" {
                
                let destination = segue.destination as! SignatureViewController
                destination.signatureType = "nilpeter"

            }
            
            if sender as! String == "customerSignature" {
                
                let destination = segue.destination as! SignatureViewController
                destination.signatureType = "customer"
                
            }

        }
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        loadingLabel.isHidden = true
        webView.alpha = 0.85
        
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
        loadingLabel.isHidden = false
        webView.alpha = 0.3
    }
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        print("webViewDidStartLoad")
        showLoading()
    
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
     
        print("webViewDidFinishLoad")
        hideLoading()
        webView.stringByEvaluatingJavaScript(from: Timesheet.nilpeterSignature)
        webView.stringByEvaluatingJavaScript(from: Timesheet.customerSignature)
        
    }
    
    @IBAction func clearNilpeterSig(_ sender: Any) {
        let script = "signaturePad.clear();"
        webView.stringByEvaluatingJavaScript(from: script)
        Timesheet.hasTyped = true
        Timesheet.nilpeterSignature = ""
    }
    
    @IBAction func clearCustomerSig(_ sender: Any) {
        let script = "signaturePad2.clear();"
        webView.stringByEvaluatingJavaScript(from: script)
        Timesheet.hasTyped = true
        Timesheet.nilpeterSignature = ""
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        print("An error occurred while loading the webview")
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        
        
        
        let script = "$('#submitButton').trigger('click')"
               webView.stringByEvaluatingJavaScript(from: script)
        
        Timesheet.hasTyped = false
        
        if createEdit == "/iostimesheet/" {
            alertFromCreate("fromCreate")
        }
        
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        
        if (!Timesheet.hasTyped) {
            navigationController?.popToRootViewController(animated: true)
        } else {
            alert("back")
        }
        
        
    }
    
}
