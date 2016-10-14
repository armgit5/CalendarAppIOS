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
    var fromEditPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if product == nil {
            product = Product()
            self.showLoading()
            self.getProducts()
        }
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        
        loadingLabel = UILabel.init(frame: CGRect(x: view.center.x - 40, y: view.center.y - 40, width: 80, height: 80))
        loadingLabel.text = "Loading..."
        self.loadingLabel.isHidden = true
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.frame = CGRect(x: view.center.x - 40, y: view.center.y - 65, width: 80, height: 80)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        
    }
    
    func getProducts() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("products", idString: nil) {
            products in
            if let productArray = products {
                DispatchQueue.main.async {
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
        loadingLabel.isHidden = true
    }
    
    func showLoading() {
        spinner.startAnimating()
        loadingLabel.isHidden = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let otherProducts = self.product?.otherProductArray {
            return otherProducts.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "otherCell")
        
        if let nilpeterProducts = self.product?.otherProductArray {
            cell?.textLabel!.text = nilpeterProducts[(indexPath as NSIndexPath).row]
        }
        
        if self.product?.otherProductArray != nil {
            let product = self.product?.otherProductArray![(indexPath as NSIndexPath).row]
            if isSelected(product!) {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)
        let product = self.product?.otherProductArray![(indexPath as NSIndexPath).row]
        
        if isSelected(product!) {
            cell!.accessoryType = UITableViewCellAccessoryType.none
            
            for selectedProduct in selectedProducts! {
                if product == selectedProduct {
                    if let index = selectedProducts?.index(of: selectedProduct) {
                        selectedProducts?.remove(at: index)
                    }
                }
            }
            
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            selectedProducts?.append(product!)
        }
    }
    
    @IBAction func dismissController(_ sender: AnyObject) {
        if fromEditPage {
            self.performSegue(withIdentifier: "editOtherProductsSelected", sender: self)
        } else {
            self.performSegue(withIdentifier: "otherProductSelected", sender: self)
        }
        
    }
    
    func isSelected(_ product: String) -> Bool {
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
