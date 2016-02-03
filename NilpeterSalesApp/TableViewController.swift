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
                            print(company_name)
                            self.products.append(company_name)
                            self.details.append("test")
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath)
        cell.textLabel!.text = self.products[indexPath.row]
        cell.detailTextLabel!.text = self.details[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .Normal, title: "Share") { (UITableViewRowAction, indexPath) -> Void in
            let firstActivityItem = self.products[indexPath.row]
            let acitivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            self.presentViewController(acitivityViewController, animated: true, completion: nil)
            
        }
        
        let shareAction2 = UITableViewRowAction(style: .Normal, title: "Share2") { (UITableViewRowAction, indexPath) -> Void in
            let firstActivityItem = self.products[indexPath.row]
            let acitivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
            self.presentViewController(acitivityViewController, animated: true, completion: nil)
            
        }
        
        shareAction.backgroundColor = UIColor.blackColor()
        shareAction2.backgroundColor = UIColor.redColor()
        return [shareAction, shareAction2]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(products[indexPath.row])
        
        performSegueWithIdentifier("showEditTable", sender: self)
    }

}
