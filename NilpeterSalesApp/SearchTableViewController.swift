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
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        
        // Spinner
        loadingLabel = UILabel.init(frame: CGRect(x: 55, y: 0, width: 80, height: 40))
        loadingLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 14)
        loadingLabel.text = "Updating..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.frame = CGRect(x: 5, y: 0, width: 80, height: 40)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        self.hideLoading()
        
        // Operation
        
        // print("viewdidappear")
        if company == nil {
            self.showLoading()
            self.getComapnies()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // print("viewwillappear")
        // print(company)
        //self.getComapnies()
        
        if let loadedCompanies = company {
            print("company exists")
            if loadedCompanies.companies.count == 0 {
                self.showLoading()
                self.getComapnies()
            }
        } else {
            print("not exists")
            self.showLoading()
            self.getComapnies()
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
    
    // MARK: - Get companies
    
    func getComapnies() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("companies", idString: nil) {
            companies in
            
            print(companies)
            if let comArray = companies {
                DispatchQueue.main.async {
                    let comArrayObj = Company(dictArray: comArray)
                    self.company?.companies = comArrayObj.companyArray!
                    self.company?.parentCompanyDict = comArrayObj.companyDict
                    print("trying to load")
                    self.tableView.reloadData()
                    self.hideLoading()
                }
            }
        }
    }
    
    // MARK: - tableview stuffs
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.resultSearchController.isActive) {
            return (self.company?.filteredCompanies.count)!
        }
        else {
            return (self.company?.companies.count)!
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if (self.resultSearchController.isActive) {
            cell.textLabel?.text = self.company?.filteredCompanies[(indexPath as NSIndexPath).row]
            return cell        }
        else {
            cell.textLabel?.text = self.company?.companies[(indexPath as NSIndexPath).row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var apple = ""
        
        if (self.resultSearchController.isActive) {
            apple = (self.company?.filteredCompanies[(indexPath as NSIndexPath).row])!
        } else {
            apple = (self.company?.companies[(indexPath as NSIndexPath).row])!
        }
        
        if  !apple.isEmpty {
            company?.parentCompany = apple
            company?.parentCompanyId = company?.parentCompanyDict![apple]
            self.dismiss(animated: false, completion: nil)
            self.performSegue(withIdentifier: "companySelected", sender: self)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        self.company?.filteredCompanies.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = ((self.company?.companies)! as NSArray).filtered(using: searchPredicate)
        self.company?.filteredCompanies = array as! [String]
        self.tableView.reloadData()
    }
    
    // MARK - pull to reload companies
    
    @IBAction func refreshCompanies() {
        getComapnies()
        refreshControl?.endRefreshing()
    }
    
}
