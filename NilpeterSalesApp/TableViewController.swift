//
//  TableViewController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 2/2/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var id: Int = 0
    // User store
    var prefs: NSUserDefaults!
    
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        let font: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 17)!
        let color = UIColor.whiteColor()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font,NSForegroundColorAttributeName: color], forState: .Normal)
        
        prefs = NSUserDefaults.standardUserDefaults()
        
        loadingLabel = UILabel.init(frame: CGRectMake(self.view.frame.size.width - 75, 0, 80, 40))
        loadingLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 14)
        loadingLabel.text = "Updating..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        spinner.frame = CGRectMake(self.view.frame.size.width - 125, 0, 80, 40)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getSchedules()
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
    
    func removeSchedules() {
        Schedules.title.removeAll()
        Schedules.details.removeAll()
    }
    
    func getSchedules() {
        showLoading()
        let scheduleService = ScheduleService()
        let userIdString = String(self.prefs.integerForKey("Userid"))
        scheduleService.getSchedule("schedules/index/)", idString: userIdString) {
            schedules in
            if let scheduleArray = schedules {
                dispatch_async(dispatch_get_main_queue()) {
                    self.removeSchedules()
                    for schedule in scheduleArray {
                        var words = ""
                        if let date = schedule["date"] as? String {
                            words = date
                        }
                        if let company_name = schedule["company_name"] as? String {
                            words = words + ", " + company_name
                        }
                        if let details = schedule["project"] as? String {
                            Schedules.details.append(details)
                        } else {
                            Schedules.details.append("No Details...")
                        }
                      
                        let scheduleId = schedule["id"] as! Int
                        Schedules.title.append([words:scheduleId])
                        
                    }
                    self.tableView.reloadData()
                    // print(Schedules.title)
                    self.hideLoading()
                }
            }
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Schedules.title.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        cell.textLabel!.text = Schedules.title[indexPath.row].keys.first
        cell.detailTextLabel?.text = Schedules.details[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "DELETE") { (UITableViewRowAction, indexPath) -> Void in
            if let id = Schedules.title[indexPath.row].values.first {
                let idString = String(id)
                self.postToArm(idString)
            }
        }
        shareAction.backgroundColor = UIColor.redColor()
        return [shareAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // print(Schedules.title[indexPath.row].values.first)
        id = Schedules.title[indexPath.row].values.first!
        performSegueWithIdentifier("showEditTable", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditTable" {
            if let destination = segue.destinationViewController as? TableViewEditController {
                destination.id = id
            }
        }
    }
    
    func postToArm(postId: String?) {
        
        // Send to the cloud
        let body = ""
        
        let scheduleService = ScheduleService()
        scheduleService.postSchedule(body,postId: postId, postMethod: "DELETE") {
            status in
            if let returnMessage = status as String? {
                print(returnMessage)
                dispatch_async(dispatch_get_main_queue()) {
                    print("successfully deleted")
                    self.getSchedules()
                }
            }
        }
    }


}
