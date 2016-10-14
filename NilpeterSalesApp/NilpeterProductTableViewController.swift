//
//  ProductsTableViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/25/2558 BE.
//  Copyright © 2558 Arm Suwansiri. All rights reserved.
//

import UIKit

class NilpeterProductTableViewController: UITableViewController {
    
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
    
    // MARK: - Helper function
    
    func hideLoading() {
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
    }
    
    func showLoading() {
        if !fromEditPage {
            self.spinner.startAnimating()
            self.loadingLabel.isHidden = false
        }
        
    }
    
    // MARK: - Get products
    
    func getProducts() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("products", idString: nil) {
            products in
            if let productArray = products {
                DispatchQueue.main.async {
                    let productArrayObj = Product(dictArray: productArray)
                    self.product?.nilpeterProductArray = productArrayObj.nilpeterProductArray
                    self.product?.productDict = productArrayObj.productDict
                    self.tableView.reloadData()
                    self.hideLoading()
                }
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let nilpeterProducts = self.product?.nilpeterProductArray {
            return nilpeterProducts.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nilpeterCell")
        
        if let nilpeterProducts = self.product?.nilpeterProductArray {
            cell?.textLabel!.text = nilpeterProducts[(indexPath as NSIndexPath).row]
        }
        
        if self.product?.nilpeterProductArray != nil {
            let product = self.product?.nilpeterProductArray![(indexPath as NSIndexPath).row]
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
        let product = self.product?.nilpeterProductArray![(indexPath as NSIndexPath).row]
        
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
            self.performSegue(withIdentifier: "editNilpeterProductsSelected", sender: self)
        } else {
            self.performSegue(withIdentifier: "nilpeterProductsSelected", sender: self)
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
