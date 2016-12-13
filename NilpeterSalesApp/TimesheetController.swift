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
    
    
    var hasTyped = false
    
    var prefs: UserDefaults!
    var webScript: String!
    
    var id: String!
    var createEdit: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.prefs = UserDefaults.standard
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = URL(string: User.headingBaseURL + "ioscalendar" + createEdit + id)
        print(url!)
        
        let request = URLRequest(url: url!)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(request)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        print("typing")
        hasTyped = true
    }

    func alert(_ sig: String) {
        let alert = UIAlertController(title: "Alert", message: "Please press yes to go back and save the changes, press no go to cotinue without saving", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: nil)
        let cancelAction =  UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: {
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
            
            
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func nilpeterSignature(_ sender: AnyObject) {
        
        if (!hasTyped) {
            performSegue(withIdentifier: "showSignature", sender: "nilpeterSignature")
        } else {
            alert("nilSig")
        }
        
    }
    
    @IBAction func customerSignature(_ sender: AnyObject) {
        if (!hasTyped) {
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
    }
    
    
    @IBAction func clearCustomerSig(_ sender: Any) {
        let script = "signaturePad2.clear();"
        webView.stringByEvaluatingJavaScript(from: script)
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        print("An error occurred while loading the webview")
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        
        
        
        let script = "$('#submitButton').trigger('click')"
               webView.stringByEvaluatingJavaScript(from: script)
        
//        self.submitButton.enabled = false
        hasTyped = false
        
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        if (!hasTyped) {
            navigationController?.popToRootViewController(animated: true)
        } else {
            alert("back")
        }
    }
    
}
