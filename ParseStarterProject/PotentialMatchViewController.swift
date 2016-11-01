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
    var userSelectedPM = String()
    var skillDescriptionTitlePM = ""
    var hasSkillTablePM = true
    @IBOutlet var userProfileLabel: UILabel!
    @IBAction func matchButton(_ sender: AnyObject) {
    }
    
    @IBOutlet var userSkillsLabel: UILabel!
    @IBOutlet var userWantsLabel: UILabel!
    @IBOutlet var skillsTable: UITableView!
    @IBOutlet var wantsTable: UITableView!
    @IBOutlet var profileDescription: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("user selected \(userSelectedPM)")

        userProfileLabel.text = userSelectedPM
        userSkillsLabel.text = "\(userSelectedPM)'s Skills"
        userWantsLabel.text = "\(userSelectedPM) would like to learn:"
        
        let querySkills = PFQuery(className: "Skills")
        querySkills.whereKey("hasSkill", contains: userSelectedPM)
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
        queryInterests.whereKey("wantsSkill", contains: userSelectedPM)
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
        
        
        // profile image and description
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: userSelectedPM)
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        if object["photo"] != nil {
                            print("photo found")
                            let profileData = object["photo"] as! PFFile
                            print("profile Data \(profileData)")
                            profileData.getDataInBackground { (data, error) in
                                if let imageData = data {
                                    if let downloadedImage = UIImage(data: imageData) {
                                        //var imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: self.profileImage.frame.size.width - 20, height: self.profileImage.frame.size.height - 20))
                                        //imageView.image = downloadedImage
                                        self.profileImage.image = downloadedImage
                                        self.backgroundImage.image = downloadedImage
                                    }
                                }
                            }
                        }
                        if let text = object["description"] as? String {
                            print("text \(text)")
                            self.profileDescription.text = text
                        }
                    }
                } else {
                    print("no objects")
                }
            }
        }
        
        skillsTable.tableFooterView = UIView()
        wantsTable.tableFooterView = UIView()
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
            skillDescriptionTitlePM = skills[indexPath.row]
            hasSkillTablePM = true
            
        } else {
            // wants table
            skillDescriptionTitlePM = interests[indexPath.row]
            hasSkillTablePM = false

        }
        performSegue(withIdentifier: "SkillDesSegue", sender: self)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "SkillDesSegue") {
            let skillDesVC = segue.destination as! SkillDescriptionViewController
            skillDesVC.editMode = false
            skillDesVC.skillDescriptionTitleSD = skillDescriptionTitlePM
            skillDesVC.userSelectedSD = userSelectedPM
            skillDesVC.hasSkillTableSD = hasSkillTablePM
            
        }
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
