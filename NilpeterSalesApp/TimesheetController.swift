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
    
    var prefs: NSUserDefaults!
    var webScript: String!
    
    var id: String!
    var createEdit: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        self.prefs = NSUserDefaults.standardUserDefaults()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = NSURL(string: User.headingBaseURL + "ioscalendar" + createEdit + id)
        print(url)
        
        let request = NSURLRequest(URL: url!)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(request)
        
    }
    
    @IBAction func nilpeterSignature(sender: AnyObject) {
        performSegueWithIdentifier("showSignature", sender: "nilpeterSignature")
    }
    
    @IBAction func customerSignature(sender: AnyObject) {
        webView.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSignature" {
            if sender as! String == "nilpeterSignature" {
                
                let destination = segue.destinationViewController as! SignatureViewController
                destination.signatureType = "nilpeter"

            }
            
            if sender as! String == "customerSignature" {
                
                let destination = segue.destinationViewController as! SignatureViewController
                destination.signatureType = "customer"
                
            }

        }
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingIndicator.hidden = true
        loadingLabel.hidden = true
        webView.alpha = 0.85
        
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        loadingIndicator.hidden = false
        loadingLabel.hidden = false
        webView.alpha = 0.3
    }
    
    func webViewDidStartLoad(webView: UIWebView)
    {
        print("webViewDidStartLoad")
        showLoading()
    }
    
    func webViewDidFinishLoad(webView: UIWebView)
    {
     
        print("webViewDidFinishLoad")
        hideLoading()
        webView.stringByEvaluatingJavaScriptFromString(Timesheet.nilpeterSignature)
        webView.stringByEvaluatingJavaScriptFromString(Timesheet.customerSignature)

        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        print("An error occurred while loading the webview")
    }
    
    @IBAction func submit(sender: AnyObject) {
        
        let script = "$('#submitButton').trigger('click')"
               webView.stringByEvaluatingJavaScriptFromString(script)
        
        self.submitButton.enabled = false
        
    }
    
    @IBAction func dismissViewController(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
