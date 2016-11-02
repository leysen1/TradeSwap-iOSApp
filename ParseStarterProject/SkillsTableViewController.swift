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

     Make profile view nice
     
     Think about how to add skill evidence (on profile, click skill and it takes you to an upload page, like a feed.)
 */
    
    var skillsArray = [String]()
    var hasSkill = [String: Bool]()
    var wantsSkill = [String: Bool]()
    var showMySkills: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skills()
        
        tableView.tableFooterView = UIView()
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
                                            self.hasSkill.updateValue(true, forKey: name)
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
        return self.skillsArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.skillsArray[indexPath.row]

        if hasSkill[skillsArray[indexPath.row]]! {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if hasSkill[skillsArray[indexPath.row]] == true {
            //  unclicking a skill
            hasSkill[skillsArray[indexPath.row]] = false
            cell?.accessoryType = UITableViewCellAccessoryType.none
            
            let query = PFQuery(className: "Skills")
            query.whereKey("name", equalTo: skillsArray[indexPath.row])
            
            query.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    if let objects = objects {
                        for object in objects {
                            object.remove((PFUser.current()?.username!)!, forKey: "hasSkill")
                            object.saveInBackground()
                        }
                    }
                }
            })
            
        } else {
            // clicking a skill
            hasSkill[skillsArray[indexPath.row]] = true
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            let query = PFQuery(className: "Skills")
            query.whereKey("name", equalTo: skillsArray[indexPath.row])
            
            query.findObjectsInBackground(block: { (objects, error) in
                if error != nil {
                    print(error)
                } else {
                    if let objects = objects {
                        for object in objects {
                            object.addUniqueObject((PFUser.current()?.username!)!, forKey: "hasSkill")
                            object.saveInBackground()
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
