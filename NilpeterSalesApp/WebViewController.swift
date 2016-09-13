//
//  WebViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/30/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var loadingLabel: UILabel!
    
    var prefs: NSUserDefaults!
    var webScript: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        // self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        
        self.prefs = NSUserDefaults.standardUserDefaults()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = NSURL(string: User.headingBaseURL + "ioscalendar")
        
        let request = NSURLRequest(URL: url!)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(request)
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
//        let contentSize:CGSize = webView.scrollView.contentSize
//        let viewSize:CGSize = self.view.bounds.size
//        
//        let rw = viewSize.width / contentSize.width
//        
//        webView.scrollView.minimumZoomScale = rw
//        webView.scrollView.maximumZoomScale = rw
//        webView.scrollView.zoomScale = rw
        print("webViewDidFinishLoad")
        hideLoading()
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        print("An error occurred while loading the webview")
    }
    
    @IBAction func logout(sender: AnyObject) {
        self.prefs.setValue(0, forKey: "Session")
        self.performSegueWithIdentifier("showLogin", sender: self)
        self.prefs.setValue(nil, forKey: "Userid")
        self.prefs.setValue(nil, forKey: "Email")
        self.prefs.setValue(nil, forKey: "Session")
        
//        let script = "signaturePad.clear();"
//        webView.stringByEvaluatingJavaScriptFromString(script)

//        let script = "$('#submitButton').trigger('click')"
//        webView.stringByEvaluatingJavaScriptFromString(script)
    }
    

}
