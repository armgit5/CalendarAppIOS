//
//  SearchTableViewController.swift
//  NilpeterSalesApp
//
//  Created by Yuttanant Suwansiri on 9/3/2558 BE.
//  Copyright (c) 2558 Arm Suwansiri. All rights reserved.
//

import Foundation
import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var company: Company?
    var resultSearchController = UISearchController()
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Result Controller
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
        // UI stuff
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        
        // Spinner
        loadingLabel = UILabel.init(frame: CGRectMake(55, 0, 80, 40))
        loadingLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 14)
        loadingLabel.text = "Updating..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(5, 0, 80, 40)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        self.hideLoading()
        
        // Operation
        if company == nil {
            self.showLoading()
            self.getComapnies()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.getComapnies()
        
        if company?.companies == nil {
            self.showLoading()
            self.getComapnies()
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
    
    // MARK: - Get companies
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            
            if let comArray = companies {
                dispatch_async(dispatch_get_main_queue()) {
                    let comArrayObj = Company(dictArray: comArray)
                    self.company?.companies = comArrayObj.companyArray!
                    self.company?.parentCompanyDict = comArrayObj.companyDict
                    self.tableView.reloadData()
                    self.hideLoading()
                }
            }
        }
    }
    
    // MARK: - tableview stuffs
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.active) {
            return (self.company?.filteredCompanies.count)!
        }
        else {
            return (self.company?.companies.count)!
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if (self.resultSearchController.active) {
            cell.textLabel?.text = self.company?.filteredCompanies[indexPath.row]
            return cell        }
        else {
            cell.textLabel?.text = self.company?.companies[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var apple = ""
        
        if (self.resultSearchController.active) {
            apple = (self.company?.filteredCompanies[indexPath.row])!
        } else {
            apple = (self.company?.companies[indexPath.row])!
        }
        
        if  !apple.isEmpty {
            company?.parentCompany = apple
            company?.parentCompanyId = company?.parentCompanyDict![apple]
            self.dismissViewControllerAnimated(false, completion: nil)
            self.performSegueWithIdentifier("companySelected", sender: self)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        self.company?.filteredCompanies.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = ((self.company?.companies)! as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.company?.filteredCompanies = array as! [String]
        self.tableView.reloadData()
    }
    
    // MARK - pull to reload companies
    
    @IBAction func refreshCompanies() {
        getComapnies()
        refreshControl?.endRefreshing()
    }
    
}
