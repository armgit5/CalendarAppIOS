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
    
    var prefs: UserDefaults!
    var webScript: String!
    
    var id: String!
    var createEdit: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.prefs = UserDefaults.standard

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = URL(string: User.headingBaseURL + "ioscalendar" + createEdit + id)
        print(url)
        
        let request = URLRequest(url: url!)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(request)
        
    }
    
    @IBAction func nilpeterSignature(_ sender: AnyObject) {
        performSegue(withIdentifier: "showSignature", sender: "nilpeterSignature")
    }
    
    @IBAction func customerSignature(_ sender: AnyObject) {
        performSegue(withIdentifier: "showSignature", sender: "customerSignature")
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
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        print("An error occurred while loading the webview")
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        
        let script = "$('#submitButton').trigger('click')"
               webView.stringByEvaluatingJavaScript(from: script)
        
//        self.submitButton.enabled = false
        
    }
    
    @IBAction func dismissViewController(_ sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
