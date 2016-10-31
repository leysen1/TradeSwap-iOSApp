//
//  TableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 21/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController, UINavigationControllerDelegate {
    
    // shows users with similar interests in your area
    
    var students = [String]()
    var teachers = [String]()

    @IBAction func logout(_ sender: AnyObject) {
        PFUser.logOut()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get students
        let query = PFQuery(className: "Skills")
        query.whereKey("hasSkill", contains: (PFUser.current()?.username!))
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        if let studentCol = object["wantsSkill"] as? NSArray {
                            for student in studentCol {
                                if self.students.contains(student as! String) == false {
                                    self.students.append(student as! String)
                                } else {
                                    //do nothing
                                }
                            }
                        }
                    }
                     self.tableView.reloadData()
                }
                print("students \(self.students)")
            }
        }
       
        
        

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return students.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainTableViewCell

        cell.userLabel.text = students[indexPath.row]
        
        let query = PFQuery(className: "Skills")
        query.whereKey("wantsSkill", contains: students[indexPath.row])
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                var interests = [String]()
                if let objects = objects {
                    for object in objects {
                        interests.append(object["name"] as! String)
                    }
                    var interestsString = String()
                    for item in interests {
                        interestsString.append(item)
                        interestsString.append(", ")
                    }
             
                    cell.interestedInLabel.text = "Interested in: \(interestsString)"
                }
            }
        }
        
        let query2 = PFQuery(className: "Skills")
        query2.whereKey("hasSkill", contains: students[indexPath.row])
        query2.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                var abilities = [String]()
                if let objects = objects {
                    for object in objects {
                        abilities.append(object["name"] as! String)
                    }
                    var abilitiesString = String()
                    for item in abilities {
                        abilitiesString.append(item)
                        abilitiesString.append(", ")
                    }
              
                    cell.abilitiesLabel.text = "Abilities: \(abilitiesString)"
                }
            }
        }
        

        return cell
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
