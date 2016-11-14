//
//  SkillsTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 23/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class SkillsTableViewController: UITableViewController {
    
    /*
 To Do:
     sort table sections into groups
  
 */

    var skillsArray = [String]()
    var hasSkill = [String: Bool]()
    var wantsSkill = [String: Bool]()
    var showMySkills: Bool = true
    let searchController = UISearchController(searchResultsController: nil)
    var filteredSkillsArray = [String]()
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredSkillsArray = skillsArray.filter({ (skill) -> Bool in
            return skill.lowercased().contains(searchText.lowercased())
            
        })
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        skills()
        
        tableView.tableFooterView = UIView()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    
    func skills() {
        
        // create array of all skills
        let query = PFQuery(className: "Skills")
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            }
            else {
                
                if let objects = objects {
                    for skill in objects {
                        if let skillObject = skill["name"] as? String {
                            self.skillsArray.append(skillObject)
                            self.hasSkill[skillObject] = false
                            self.wantsSkill[skillObject] = false
                            }
                            self.tableView.reloadData()
                        
                       if self.showMySkills == true {
                        // identify which skills you have
                        let query2 = PFQuery(className: "Skills")
                        query2.whereKey("hasSkill", contains: (PFUser.current()?.username!)!)
                        query2.findObjectsInBackground(block: { (objects, error) in
                            if error != nil {
                                print(error)
                            } else {
                                if let objects = objects {
                                    for object in objects {
                                        let name = object["name"] as! String
                                        self.hasSkill.updateValue(true, forKey: name)
                                    }
                                }
                                self.tableView.reloadData()
                            }
                        })
                        } else {
                            // identify which skills you want
                            let query2 = PFQuery(className: "Skills")
                            query2.whereKey("wantsSkill", contains: (PFUser.current()?.username!)!)
                            query2.findObjectsInBackground(block: { (objects, error) in
                                if error != nil {
                                    print(error)
                                } else {
                                    if let objects = objects {
                                        for object in objects {
                                            let name = object["name"] as! String
                                            self.wantsSkill.updateValue(true, forKey: name)
                                        }
                                    }
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    }
                    
                    }
                else {
                    print("no skills found")
                }
      
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        print("has skills: \(self.hasSkill)")
        print("wants skills: \(self.wantsSkill)")
        print("all skills: \(self.skillsArray)")
        
        if showMySkills == true {
            self.title = "My Skills"
        } else {
            self.title = "Skills I Want"
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSkillsArray.count
        }
        
        return self.skillsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // need to update the dictionary with checkmarks as well...
        
        if searchController.isActive && searchController.searchBar.text != "" {
            // filtering 
            
            cell.textLabel?.text = self.filteredSkillsArray[indexPath.row]
            
            cell.accessoryType = UITableViewCellAccessoryType.none
            
            if self.showMySkills == true {
            
                if hasSkill[filteredSkillsArray[indexPath.row]]! {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                
                }
            } else {
                // show my skills = false
                if wantsSkill[filteredSkillsArray[indexPath.row]]! {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
            
        } else {
            // no filter
            
            cell.textLabel?.text = self.skillsArray[indexPath.row]
            
            cell.accessoryType = UITableViewCellAccessoryType.none
            
            if self.showMySkills == true {
                if hasSkill[skillsArray[indexPath.row]]! {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            } else {
                // show my skills = false
                if wantsSkill[skillsArray[indexPath.row]]! {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
        }

        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        var searchActive = false
        
        if showMySkills == true {
            // has Skills 
            // filter
            if searchController.isActive && searchController.searchBar.text != "" {
                searchActive = true
                if hasSkill[filteredSkillsArray[indexPath.row]] == true {
                    hasSkill[filteredSkillsArray[indexPath.row]] = false
                    cell?.accessoryType = UITableViewCellAccessoryType.none
                } else {
                    hasSkill[filteredSkillsArray[indexPath.row]] = true
                    cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                    }
            } else {
                // no filter
                searchActive = false
                if hasSkill[skillsArray[indexPath.row]] == true {
                    // uncheck
                    hasSkill[skillsArray[indexPath.row]] = false
                    cell?.accessoryType = UITableViewCellAccessoryType.none
            
                } else {
                    // check
                    hasSkill[skillsArray[indexPath.row]] = true
                    cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }

            let query = PFQuery(className: "Skills")
            query.whereKey("name", equalTo: skillsArray[indexPath.row])
            
            query.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    if let objects = objects {
                        for object in objects {
                            if searchActive {
                                print("search active")
                                // filter
                                if self.hasSkill[self.filteredSkillsArray[indexPath.row]]! == false {
                                    print("unchecked")
                                    object.remove((PFUser.current()?.username!)!, forKey: "hasSkill")
                                } else {
                                    object.addUniqueObject((PFUser.current()?.username!)!, forKey: "hasSkill")
                                    print("checked")
                                }
                                object.saveInBackground()
                            } else {
                            // no filter
                                if self.hasSkill[self.skillsArray[indexPath.row]]! == false {
                                // remove skill
                                    object.remove((PFUser.current()?.username!)!, forKey: "hasSkill")
                                } else {
                                // add skill
                                    object.addUniqueObject((PFUser.current()?.username!)!, forKey: "hasSkill")
                                }
                                object.saveInBackground()
                            }
                            
                            
                        }
                    }
                }
            })
            
        } else {
            // wants Skills
            
            if searchController.isActive && searchController.searchBar.text != "" {
                searchActive = true
                if wantsSkill[filteredSkillsArray[indexPath.row]] == true { // uncheck
                    wantsSkill[filteredSkillsArray[indexPath.row]] = false
                    cell?.accessoryType = UITableViewCellAccessoryType.none
                } else { // check
                    wantsSkill[filteredSkillsArray[indexPath.row]] = true
                    cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            } else {
            // no filter
                searchActive = false
                if wantsSkill[skillsArray[indexPath.row]] == true { // uncheck
                    wantsSkill[skillsArray[indexPath.row]] = false
                    cell?.accessoryType = UITableViewCellAccessoryType.none
                
                } else { // check
                    wantsSkill[skillsArray[indexPath.row]] = true
                    cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
            let query = PFQuery(className: "Skills")
            query.whereKey("name", equalTo: skillsArray[indexPath.row])
            
            query.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    if let objects = objects {
                        for object in objects {
                            if searchActive {
                                // filter
                                if self.wantsSkill[self.filteredSkillsArray[indexPath.row]]! == false {
                                    object.remove((PFUser.current()?.username!)!, forKey: "wantsSkill")
                                } else {
                                    object.addUniqueObject((PFUser.current()?.username!)!, forKey: "wantsSkill")
                                }
                                object.saveInBackground()
                            } else {
                                // no filter
                                if self.wantsSkill[self.skillsArray[indexPath.row]]! == false {
                                    // remove skill
                                    object.remove((PFUser.current()?.username!)!, forKey: "wantsSkill")
                                } else {
                                    // add skill
                                    object.addUniqueObject((PFUser.current()?.username!)!, forKey: "wantsSkill")
                                }
                                object.saveInBackground()
                            }
                            
                            
                        }
                    }
                }
            })
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Skills"
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SkillsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
