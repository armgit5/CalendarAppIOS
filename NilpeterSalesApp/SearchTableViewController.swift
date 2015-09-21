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
    
    var companies: [String] = []
    var filteredCompanies = [String]()
    var resultSearchController = UISearchController()
    
    var parentCompany: String?
    var parentCompanyDict: [String: Int]?
    var parentCompanyId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        self.tableView.reloadData()
        
        getComapnies()
        
    }
    
    // MARK: - Get companies
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies") {
            companies in
            
            if let comArray = companies {
                dispatch_async(dispatch_get_main_queue()) {
                    let comArrayObj = Company(dictArray: comArray)
                    self.companies = comArrayObj.companyArray!
                    self.parentCompanyDict = comArrayObj.companyDict
                    self.tableView.reloadData()
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
            return self.filteredCompanies.count
        }
        else {
            return self.companies.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if (self.resultSearchController.active) {
            cell.textLabel?.text = self.filteredCompanies[indexPath.row]
            return cell        }
        else {
            cell.textLabel?.text = self.companies[indexPath.row]
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var apple = ""
        
        if (self.resultSearchController.active) {
            apple = self.filteredCompanies[indexPath.row]
        } else {
            apple = self.companies[indexPath.row]
        }
        
        if  !apple.isEmpty {
            parentCompany = apple
            parentCompanyId = parentCompanyDict![apple]
            self.performSegueWithIdentifier("companySelected", sender: self)
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        self.filteredCompanies.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.companies as NSArray).filteredArrayUsingPredicate(searchPredicate)
        self.filteredCompanies = array as! [String]
        self.tableView.reloadData()
    }
    
    // MARK - pull to reload companies
    
    @IBAction func refreshCompanies() {
        getComapnies()
        refreshControl?.endRefreshing()
    }
    
}
