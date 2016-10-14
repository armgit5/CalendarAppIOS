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
    var prefs: UserDefaults!
    var fromEditPage: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefs = UserDefaults.standard
        if prefs.integer(forKey: "Session") == 0 {
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
        
//        if (Engineer.engineerArray.count < 2) {
////            self.showLoading()
//            Engineer.rawEngineerData.removeAll()
//            Engineer.engineerArray.removeAll()
//            Engineer.engineerDict.removeAll()
//
//            self.getEngineers()
//         }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        
        loadingLabel = UILabel.init(frame: CGRect(x: view.center.x - 40, y: view.center.y - 40, width: 80, height: 80))
        loadingLabel.text = "Loading..."
        self.loadingLabel.isHidden = true
        spinner = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.frame = CGRect(x: view.center.x - 40, y: view.center.y - 65, width: 80, height: 80)
        view.addSubview(spinner)
        view.addSubview(loadingLabel)
        
    }

    
    func getEngineers() {
        let scheduleService = ScheduleService()
        scheduleService.getSchedule("engineers", idString: nil) {
            engineers in
            if let engineerArray = engineers {
                DispatchQueue.main.async {
                    for engineer in engineerArray {
                        if let engineertName = engineer["email"] as? String {
                            if engineertName == "admin@nilpeter.com" {
                                print("don't add admin")
                            } else if engineertName == "ios@nilpeter.com" {
                                print("don't add ios")
                            } else if engineertName == self.prefs.string(forKey: "Email") {
                                print(engineertName)
                                print("dont' add current user")
                            } else {
                                Engineer.engineerArray.append(engineertName)
                                if let engineerId = engineer["id"] as? Int {
                                    Engineer.engineerDict[engineertName] = engineerId
                                }
                            }
                            
                        }
                    }
                    self.tableView.reloadData()
                    print(Engineer.engineerArray)
                }
            }
        }
    }


    
    // MARK: - Helper function
    
//    func hideLoading() {
//        self.spinner.stopAnimating()
//        self.loadingLabel.hidden = true
//    }
//    
//    func showLoading() {
//        self.spinner.startAnimating()
//        self.loadingLabel.hidden = false
//    }
    
    // MARK: - Get products
    
        
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Engineer.engineerArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "engineerCell")
        let engineerName: String = Engineer.engineerArray[(indexPath as NSIndexPath).row].components(separatedBy: "@")[0]
        
        cell?.textLabel?.text = engineerName
        
        let engineer = Engineer.engineerArray[(indexPath as NSIndexPath).row]
        
        if isSelected(engineer) {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath)
        let engineer = Engineer.engineerArray[(indexPath as NSIndexPath).row]
        
        if isSelected(engineer) {
            cell!.accessoryType = UITableViewCellAccessoryType.none
            
            for selectedEngineer in Engineer.pickedEngineerNames {
                if engineer == selectedEngineer {
                    if let index = Engineer.pickedEngineerNames.index(of: selectedEngineer) {
                        Engineer.pickedEngineerNames.remove(at: index)
                        Engineer.pickedEngineerIds.remove(at: index)
                    }
                }
            }
            
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            Engineer.pickedEngineerNames.append(engineer)
            Engineer.pickedEngineerIds.append(Engineer.engineerDict[engineer]!)
        }
        
    }
    
    @IBAction func dismissController(_ sender: AnyObject) {
        if fromEditPage {
            self.performSegue(withIdentifier: "editEngineersSelected", sender: self)
        } else {
            self.performSegue(withIdentifier: "engineersSelected", sender: self)
        }
    }
    
    func isSelected(_ engineer: String) -> Bool {
        for selectedEngineer in (Engineer.pickedEngineerNames) {
            if engineer == selectedEngineer {
                return true
            }
        }
        return false
    }
    
    @IBAction func refreshEngineers() {
        self.tableView.reloadData()
        refreshControl?.endRefreshing()
    }


}
