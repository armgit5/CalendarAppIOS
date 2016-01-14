//
//  ThirdPartyProductTableViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/28/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import UIKit

class ThirdPartyProductTableViewController: UITableViewController {

    var product: Product?
    var selectedProducts: [String]?
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if product == nil {
            product = Product()
            self.showLoading()
            self.getProducts()
        }
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        
        loadingLabel = UILabel.init(frame: CGRectMake(view.center.x - 40, view.center.y - 40, 80, 80))
        loadingLabel.text = "Loading..."
        self.loadingLabel.hidden = true
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(view.center.x - 40, view.center.y - 65, 80, 80)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        
    }
    
    func getProducts() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("products") {
            products in
            if let productArray = products {
                dispatch_async(dispatch_get_main_queue()) {
                    let productArrayObj = Product(dictArray: productArray)
                    self.product?.otherProductArray = productArrayObj.otherProductArray
                    self.product?.productDict = productArrayObj.productDict
                    
                    self.tableView.reloadData()
                    self.hideLoading()
                }
            }
        }
    }
    
    // MARK: - Helper function
    
    func hideLoading() {
        spinner.stopAnimating()
        loadingLabel.hidden = true
    }
    
    func showLoading() {
        spinner.startAnimating()
        loadingLabel.hidden = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let otherProducts = self.product?.otherProductArray {
            return otherProducts.count
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("otherCell")
        
        if let nilpeterProducts = self.product?.otherProductArray {
            cell?.textLabel!.text = nilpeterProducts[indexPath.row]
        }
        
        if self.product?.otherProductArray != nil {
            let product = self.product?.otherProductArray![indexPath.row]
            if isSelected(product!) {
                cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
                
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let product = self.product?.otherProductArray![indexPath.row]
        
        if isSelected(product!) {
            cell!.accessoryType = UITableViewCellAccessoryType.None
            
            for selectedProduct in selectedProducts! {
                if product == selectedProduct {
                    if let index = selectedProducts?.indexOf(selectedProduct) {
                        selectedProducts?.removeAtIndex(index)
                    }
                }
            }
            
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            selectedProducts?.append(product!)
        }
    }
    
    @IBAction func dismissController(sender: AnyObject) {
        self.performSegueWithIdentifier("otherProductSelected", sender: self)
    }
    
    func isSelected(product: String) -> Bool {
        for selectedProduct in (self.selectedProducts)! {
            
            if product == selectedProduct {
                return true
            }
        }
        return false
    }
    
    @IBAction func refreshProducts() {
        getProducts()
        refreshControl?.endRefreshing()
    }

}
