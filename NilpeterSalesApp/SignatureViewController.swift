//
//  SignatureViewController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 8/11/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController, YPDrawSignatureViewDelegate {
    
    @IBOutlet weak var signatureLabel: UILabel!
    
    @IBOutlet var signatureView: YPDrawSignatureView!
    var signatureType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        
        signatureView.delegate = self;
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        if signatureType == "nilpeter" {
            signatureLabel.text = "Nilpeter's Signature:"
        }
        
        if signatureType == "customer" {
            signatureLabel.text = "Customer's Signature:"
        }
        
        
    }
    
    @IBAction func clearSignature(_ sender: AnyObject) {
        self.signatureView.clearSignature()
    }
    
    
    @IBAction func okButton(_ sender: AnyObject) {
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            
            let imageData:Data = UIImagePNGRepresentation(signatureImage)!
            let strBase64 = imageData.base64EncodedString(options: [])
            let trimmed = strBase64.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

            if signatureType == "nilpeter" {
                Timesheet.nilpeterSignature = "signaturePad.fromDataURL('data:image/png;base64,\(trimmed)')"
            }
            
            if signatureType == "customer" {
                Timesheet.customerSignature = "signaturePad2.fromDataURL('data:image/png;base64,\(trimmed)')"
            }
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func finishedSignatureDrawing() {
        print("Finished")
    }
    
    func startedSignatureDrawing() {
        print("Started")
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeLeft
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
