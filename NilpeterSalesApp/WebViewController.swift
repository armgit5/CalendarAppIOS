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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        
        let url = NSURL(string: "http://localhost:3000/ioscalendar")
        let request = NSURLRequest(URL: url!)
        
        webView.delegate = self
        webView.loadRequest(request)
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loadingLabel.hidden = true
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        loadingLabel.hidden = false
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
        
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
    {
        print("An error occurred while loading the webview")
    }

}
