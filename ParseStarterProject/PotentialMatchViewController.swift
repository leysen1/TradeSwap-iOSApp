//
//  PotentialMatchViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 31/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PotentialMatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var skills = [String]()
    var interests = [String]()
    @IBOutlet var userProfileLabel: UILabel!
    @IBAction func matchButton(_ sender: AnyObject) {
    }
    
    @IBOutlet var userSkillsLabel: UILabel!
    @IBOutlet var userWantsLabel: UILabel!
    @IBOutlet var skillsTable: UITableView!
    @IBOutlet var wantsTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileLabel.text = "\(userSelected)'s Profile"
        userSkillsLabel.text = "\(userSelected)'s Skills"
        userWantsLabel.text = "\(userSelected) would like to learn:"
        
        let querySkills = PFQuery(className: "Skills")
        querySkills.whereKey("hasSkill", contains: userSelected)
        querySkills.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        self.skills.append(object["name"] as! String)
                    }
                    self.skillsTable.reloadData()
                    print("skills\(self.skills)")
                }
            }
        }
        
        let queryInterests = PFQuery(className: "Skills")
        queryInterests.whereKey("wantsSkill", contains: userSelected)
        queryInterests.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        self.interests.append(object["name"] as! String)
                    }
                    self.wantsTable.reloadData()
                    print("interests\(self.interests)")
                }
            }
        }
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == skillsTable {
            return self.skills.count
        } else {
            // wantsTable
            return self.interests.count
        }
        
    }
 

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == skillsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SkillCell", for: indexPath)
            cell.textLabel?.text = self.skills[indexPath.row]
            return cell
        } else {
            // wants Table
            let cell = tableView.dequeueReusableCell(withIdentifier: "WantsCell", for: indexPath)
            cell.textLabel?.text = self.interests[indexPath.row]
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == skillsTable {
            performSegue(withIdentifier: "SkillDesSegue", sender: self)
            skillDescriptionTitle = skills[indexPath.row]
            
            
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let profileVC = segue.destination as! SkillDescriptionViewController
        profileVC.editMode = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
