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
    
    var prefs: UserDefaults!
    var webScript: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        // self.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        
        self.prefs = UserDefaults.standard
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = URL(string: User.headingBaseURL + "ioscalendar")
        
        let request = URLRequest(url: url!)
        webView.delegate = self
        webView.scalesPageToFit = true
        webView.loadRequest(request)
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
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        print("An error occurred while loading the webview")
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        self.prefs.setValue(0, forKey: "Session")
        self.performSegue(withIdentifier: "showLogin", sender: self)
        self.prefs.setValue(nil, forKey: "Userid")
        self.prefs.setValue(nil, forKey: "Email")
        self.prefs.setValue(nil, forKey: "Session")
        self.prefs.setValue(nil, forKey: "ServerName")
    }
    

}
