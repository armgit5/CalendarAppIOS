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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        company = Company()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
        
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
                    self.company?.companies = comArrayObj.companyArray!
                    self.company?.parentCompanyDict = comArrayObj.companyDict
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
