//
//  WebViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/30/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://localhost:3000/ioscalendar")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

}
