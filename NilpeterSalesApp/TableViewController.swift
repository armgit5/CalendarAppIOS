//
//  TableViewController.swift
//  NilpeterServiceApp
//
//  Created by Yuttanant Suwansiri on 2/2/2559 BE.
//  Copyright © 2559 Arm Suwansiri. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var products = ["Lan: MCC: L12321 : F4234","dbsa","iwds","kjdsa"]
    var details = ["dsa","fdsa","fdjahfdsa","jsuecs"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()
        getSchedules()
    }
    
    
    func getSchedules() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("schedules") {
            schedules in
            if let scheduleArray = schedules {
                dispatch_async(dispatch_get_main_queue()) {
                    for schedule in scheduleArray {
                        if let company_name = schedule["company_name"] as? String {
                            let scheduleId = schedule["id"] as! String
                            Schedules.title.append([company_name:scheduleId])
                            if let details = schedule["project"] as? String {
                                Schedules.details.append(details)
                            } else {
                                Schedules.details.append("No Details...")
                            }
                            self.tableView.reloadData()
                        }
                    }
                    print(Schedules.title)
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
//        cell.detailTextLabel!.text = Schedules.details[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "DELETE") { (UITableViewRowAction, indexPath) -> Void in
            self.postToArm("326")
        }
        
        shareAction.backgroundColor = UIColor.blackColor()
        return [shareAction]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(Schedules.title[indexPath.row].values.first)
        performSegueWithIdentifier("showEditTable", sender: self)
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
                }
            }
        }
    }


}
