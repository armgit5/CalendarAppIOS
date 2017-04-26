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
    var prefs: UserDefaults!
    
    var spinner: UIActivityIndicatorView!
    var loadingLabel: UILabel!
   
    var createEdit = ""
    var timesheetId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        let font: UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 17)!
        let color = UIColor.white
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font,NSForegroundColorAttributeName: color], for: UIControlState())
        
        prefs = UserDefaults.standard
        
        loadingLabel = UILabel.init(frame: CGRect(x: self.view.frame.size.width - 75, y: 0, width: 80, height: 40))
        loadingLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 14)
        loadingLabel.text = "Updating..."
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.frame = CGRect(x: self.view.frame.size.width - 125, y: 0, width: 80, height: 40)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSchedules()
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
    
    func removeSchedules() {
        Schedules.title.removeAll()
        Schedules.details.removeAll()
    }
    
    func getSchedules() {
        showLoading()
        let scheduleService = ScheduleService()
        let userIdString = String(self.prefs.integer(forKey: "Userid"))
//        print(userIdString)
        scheduleService.getSchedule("schedules/index/)", idString: userIdString) {
            schedules in
            if let scheduleArray = schedules {
                DispatchQueue.main.async {
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
                        if let timesheetId = schedule["timesheet_id"] as? Int {
//                            Schedules.timesheetId.append(timesheetId)
                            let scheduleId = schedule["id"] as! Int
                            Schedules.title.append([words:[scheduleId, timesheetId]])
                        } else {
//                            Schedules.details.append("No timesheet...")
                            let scheduleId = schedule["id"] as! Int
                            Schedules.title.append([words:[scheduleId, 0]])
                        }


                        
                    }
                    self.tableView.reloadData()
                    // print(Schedules.title)
                    self.hideLoading()
                }
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Schedules.title.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel!.text = Schedules.title[(indexPath as NSIndexPath).row].keys.first
        cell.detailTextLabel?.text = Schedules.details[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .normal, title: "DELETE") { (UITableViewRowAction, indexPath) -> Void in
            // print(Schedules.title[indexPath.row].values.first?[1])
            if let id = Schedules.title[(indexPath as NSIndexPath).row].values.first?.first {
                let idString = String(id)
                self.postToArm(idString)
            }
        }
    
        let timesheetAction: UITableViewRowAction!
        
        if (Schedules.title[(indexPath as NSIndexPath).row].values.first?[1])! == 0 {
            timesheetAction = UITableViewRowAction(style: .normal, title: "CREATE") { (UITableViewRowAction, indexPath) -> Void in
                self.createEdit = "/iostimesheet/"
                if let id = Schedules.title[(indexPath as NSIndexPath).row].values.first?.first {
                    let idString = String(id)
                    self.timesheetId = String(idString)
                }
                
                self.performSegue(withIdentifier: "showTimesheet", sender: self)
            }
        } else {
            timesheetAction = UITableViewRowAction(style: .normal, title: "EDIT") { (UITableViewRowAction, indexPath) -> Void in
                self.createEdit = "/edit_iostimesheet/"
                if let id = Schedules.title[(indexPath as NSIndexPath).row].values.first?[1] {
                    let idString = String(id)
                    self.timesheetId = String(idString)
                }
                self.performSegue(withIdentifier: "showTimesheet", sender: self)
            }
        }

        shareAction.backgroundColor = UIColor.red
        timesheetAction.backgroundColor = UIColor.orange
        return [shareAction, timesheetAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//         print(Schedules.title[indexPath.row].values.first)
        id = (Schedules.title[(indexPath as NSIndexPath).row].values.first?.first!)!
        performSegue(withIdentifier: "showEditTable", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditTable" {
            if let destination = segue.destination as? TableViewEditController {
                destination.id = id
            }
        }
        
        if segue.identifier == "showTimesheet" {
            if let destination = segue.destination as? TimesheetController {
                destination.id = timesheetId
                destination.createEdit = createEdit
            }
        }
        
    }
    
    func postToArm(_ postId: String?) {
        
        let alert = UIAlertController(title: "Alert", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:  { action in
            
            // Send to the cloud
            let body = ""
            
            let scheduleService = ScheduleService()
            scheduleService.postSchedule(body,postId: postId, postMethod: "DELETE") {
                status in
                if let returnMessage = status as String? {
                    print(returnMessage)
                    DispatchQueue.main.async {
                        print("successfully deleted")
                        self.getSchedules()
                    }
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }


}
