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
    // add an unrequest button?
    
    var skills = [String]()
    var interests = [String]()
    var userSelectedPM = String()
    var skillDescriptionTitlePM = ""
    var hasSkillTablePM = true
    @IBOutlet var userProfileLabel: UILabel!
    @IBOutlet var matchButtonLabel: UIButton!

    
    @IBOutlet var userSkillsLabel: UILabel!
    @IBOutlet var userWantsLabel: UILabel!
    @IBOutlet var skillsTable: UITableView!
    @IBOutlet var wantsTable: UITableView!
    @IBOutlet var profileDescription: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        skills.removeAll()
        interests.removeAll()
        
        print("user selected \(userSelectedPM)")

        userProfileLabel.text = userSelectedPM
        userSkillsLabel.text = "\(userSelectedPM)'s Skills"
        userWantsLabel.text = "\(userSelectedPM)'s Wants"
        
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
                                        self.profileImage.layer.cornerRadius = 50
                                        self.profileImage.layer.masksToBounds = true
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

        // match button
        if let requestedArray = PFUser.current()?["MatchRequest"] as? NSArray {
            if (requestedArray.contains(self.userSelectedPM)) {
                //match already requested
                print("Match already requested")
                self.matchButtonLabel.isEnabled = false
                self.matchButtonLabel.setTitle("Match Requested", for: .normal)
                self.matchButtonLabel.setTitleColor(UIColor.darkGray, for: .normal)
            }
        else {
            if let acceptedArray = PFUser.current()?["MatchAccepted"] as? NSArray {
                print("acceptedArray \(acceptedArray)")
            if (acceptedArray.contains(self.userSelectedPM)) {
                // match already accepted
                print("Match already accepted")
                self.matchButtonLabel.isEnabled = false
                self.matchButtonLabel.setTitle("Matched", for: .normal)
                self.matchButtonLabel.setTitleColor(UIColor.darkGray, for: .normal)
                
            } else {
                // match not requested nor accepted
                print("Please request match")
                self.matchButtonLabel.isEnabled = true
                self.matchButtonLabel.setTitle("Request Match", for: .normal)
            }
        }
            }
        }
    }
    
    @IBAction func matchButton(_ sender: AnyObject) {
        // we will add a new controller of chats
        
        // button is only enable if not yet requested or accepted
        PFUser.current()?.addUniqueObject(userSelectedPM, forKey: "MatchRequest")
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if error != nil {
                print(error)
            } else {
                print("Request saved")
            }
        })
        // add if both have requested, then move both names to accepted list.
        let userSelectedRequest = PFQuery(className: "_User")
        userSelectedRequest.whereKey("username", equalTo: userSelectedPM)
        userSelectedRequest.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                var userRequest = [String]()
                if let objects = objects {
                    for object in objects {
                        if let requestArray = object["MatchRequest"] as? NSArray {
                            for i in requestArray {
                                userRequest.append(i as! String)
                            }
                        }
                    }
                    if userRequest.contains((PFUser.current()?.username!)!) {
                        print("both matched")
                    // can only save the current user
                    PFUser.current()?.remove(self.userSelectedPM, forKey: "MatchRequest")
                    PFUser.current()?.addUniqueObject(self.userSelectedPM, forKey: "MatchAccepted")
                    PFUser.current()?.saveInBackground(block: { (success, error) in
                        if error != nil {
                            print(error)
                        } else {
                            print("saved user")
                        }
                    })
                    }
                }
            }
        }
        viewDidLoad()
    }
    
    /*
     for object in objects {
     object.remove((PFUser.current()?.username!)!, forKey: "MatchRequest")
     
     object.addUniqueObject((PFUser.current()?.username!)!, forKey: "MatchAccepted")
     object.saveInBackground(block: { (success, error) in
     if error != nil {
     print(error)
     } else {
     print("saved other user")
     }
     })
     }
 */
    
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
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 11)
            return cell
        } else {
            // wants Table
            let cell = tableView.dequeueReusableCell(withIdentifier: "WantsCell", for: indexPath)
            cell.textLabel?.text = self.interests[indexPath.row]
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 11)
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
