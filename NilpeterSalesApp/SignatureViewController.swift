//
//  SignatureViewController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 8/11/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController, YPDrawSignatureViewDelegate {
    
    @IBOutlet var signatureView: YPDrawSignatureView!
    var signatureType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        
        signatureView.delegate = self;
        
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    @IBAction func clearSignature(sender: AnyObject) {
        self.signatureView.clearSignature()
    }
    
    
    @IBAction func okButton(sender: AnyObject) {
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            
            let imageData:NSData = UIImagePNGRepresentation(signatureImage)!
            let strBase64 = imageData.base64EncodedStringWithOptions([])
            let trimmed = strBase64.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

            if signatureType == "nilpeter" {
                Timesheet.nilpeterSignature = "signaturePad.fromDataURL('data:image/png;base64,\(trimmed)')"
            }
            
            if signatureType == "customer" {
                Timesheet.customerSignature = "signaturePad2.fromDataURL('data:image/png;base64,\(trimmed)')"
            }
            
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func finishedSignatureDrawing() {
        print("Finished")
    }
    
    func startedSignatureDrawing() {
        print("Started")
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.LandscapeLeft
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
}