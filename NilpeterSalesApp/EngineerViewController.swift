//
//  EngineerController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 1/13/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class EngineerViewController: UITableViewController {
    
    var selectedProducts: [String]?
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (Engineer.engineerArray.count < 2) {
            self.showLoading()
            self.getEngineers()
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
    
    func getEngineers() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("engineers") {
            engineers in
            if let engineerArray = engineers {
                dispatch_async(dispatch_get_main_queue()) {
                    for engineer in engineerArray {
                        if let engineertName = engineer["email"] as? String {
                            Engineer.engineerArray.append(engineertName)
                            if let engineerId = engineer["id"] as? Int {
                                Engineer.engineerDict[engineertName] = engineerId
                            }
                            
                        }
                    }
                    print(Engineer.engineerArray)
                    print(Engineer.engineerDict)
                }
            }
        }
    }

    
    // MARK: - Helper function
    
    func hideLoading() {
        self.spinner.stopAnimating()
        self.loadingLabel.hidden = true
    }
    
    func showLoading() {
        self.spinner.startAnimating()
        self.loadingLabel.hidden = false
    }
    
    // MARK: - Get products
    
        
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Engineer.engineerArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("engineerCell")
        cell?.textLabel?.text = Engineer.engineerArray[indexPath.row]
        
        let engineer = Engineer.engineerArray[indexPath.row]
        
        if isSelected(engineer) {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let engineer = Engineer.engineerArray[indexPath.row]
        
        if isSelected(engineer) {
            cell!.accessoryType = UITableViewCellAccessoryType.None
            
            for selectedEngineer in Engineer.pickedEngineerNames {
                if engineer == selectedEngineer {
                    if let index = Engineer.pickedEngineerNames.indexOf(selectedEngineer) {
                        Engineer.pickedEngineerNames.removeAtIndex(index)
                    }
                }
            }
            
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            Engineer.pickedEngineerNames.append(engineer)
        }
        
    }
    
    @IBAction func dismissController(sender: AnyObject) {
        self.performSegueWithIdentifier("engineersSelected", sender: self)
    }
    
    func isSelected(engineer: String) -> Bool {
        for selectedEngineer in (Engineer.pickedEngineerNames) {
            if engineer == selectedEngineer {
                return true
            }
        }
        return false
    }


}
