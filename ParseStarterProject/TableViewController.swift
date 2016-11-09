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
    var userSelectedTV = String()
    var currentUserInterests = [String]()
    var username = (PFUser.current()?.username!)!
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in

        }))
        self.present(alert, animated: true, completion: nil)
    }
    

    @IBAction func logout(_ sender: AnyObject) {
        PFUser.logOut()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUserInterests.removeAll()
        self.title = "Explore"
        // get students who want a skill you have
        let query = PFQuery(className: "Skills")
        query.whereKey("hasSkill", contains: (PFUser.current()?.username!))
        query.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        // add current user skills
                        if self.currentUserInterests.contains(object["name"] as! String) == false {
                            self.currentUserInterests.append(object["name"] as! String)
                        } else {
                            // do nothing
                        }
                        // find students who want a relevant skill
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
        
        // get student who have a skill you want 
        
        let query2 = PFQuery(className: "Skills")
        query2.whereKey("wantsSkill", contains: (PFUser.current()?.username!))
        query2.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                if let objects = objects {
                    for object in objects {
                        // add current user skills 
                        if self.currentUserInterests.contains(object["name"] as! String) == false {
                            self.currentUserInterests.append(object["name"] as! String)
                        } else {
                            // do nothing
                        }
                        // find students who have a relevant skill
                        if let studentCol = object["hasSkill"] as? NSArray {
                            for student in studentCol {
                                if self.students.contains(student as! String) == false {
                                    self.students.append(student as! String)
                                } else {
                                    //do nothing
                                }
                            }
                        }
                    }
                    if self.students.contains(self.username) {
                        self.students.remove(at: self.students.index(of: self.username)!)
                        print("students \(self.students)")
                    }
                    
                    self.tableView.reloadData()
                }
                print("current user interests \(self.currentUserInterests)")
        }
    }
        
        
       
        tableView.tableFooterView = UIView()
        
        // check whether a request is matched up and change parse accordingly
        let queryMatch = PFQuery(className: "_User")
        queryMatch.whereKey("MatchAccepted", contains: (PFUser.current()?.username!)!)
        queryMatch.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                var otherAccepted = [String]()
                var userAccepted = [String]()
                if let objects = objects {
                    print("objects found")
                    for object in objects {
                        otherAccepted.append(object["username"] as! String)
                    }
                    print("otherAcceptedarray \(otherAccepted)")
                    if let userQuery = PFUser.current()?["MatchAccepted"] as? NSArray {
                        for i in userQuery {
                            userAccepted.append(i as! String)
                        }
                        print("userAcceptedarray \(userAccepted)")
                        
                        for i in otherAccepted {
                            if userAccepted.contains(i) {
                                otherAccepted.remove(at: otherAccepted.index(of: i)!)
                                
                            }
                            print("otherAccepted \(otherAccepted)")
                        }
                    }
                    
                }
                if otherAccepted.count > 0 {
                    print("you have matched with someone!")
                    PFUser.current()?.addUniqueObjects(from: otherAccepted, forKey: "MatchAccepted")
                    PFUser.current()?.removeObjects(in: otherAccepted, forKey: "MatchRequest")
                    PFUser.current()?.saveInBackground(block: { (success, error) in
                        if error != nil {
                            print(error)
                        } else {
                            print("saved")
                        }
                    })
                    self.createAlert(title: "You have new matches!", message: "Check out your chats and start talking.")
                    
                }
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
        
        // prospective match wants skill
        let queryWants = PFQuery(className: "Skills")
        queryWants.whereKey("wantsSkill", contains: students[indexPath.row])
        queryWants.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                var interests = [String]()
                if let objects = objects {
                    for object in objects {
                        if self.currentUserInterests.contains(object["name"] as! String) == true {
                            if interests.contains(object["name"] as! String) == false {
                                interests.append(object["name"] as! String)
                            }
                        } else {
                            // do nothing
                        }
                    }
                    var interestsString = String()
                    for item in interests {
                        interestsString.append(item)
                        interestsString.append(", ")
                    }
                    interestsString = String(interestsString.characters.dropLast(2))
                    print("interestsstring \(interestsString)")
                    cell.interestedInLabel.text = "Interest's: \(interestsString)"
                }
            }
        }
        
        // prospective match has skill
        let queryHas = PFQuery(className: "Skills")
        queryHas.whereKey("hasSkill", contains: students[indexPath.row])
        queryHas.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            } else {
                var interests = [String]()
                if let objects = objects {
                    for object in objects {
                        if self.currentUserInterests.contains(object["name"] as! String) == true {
                            if interests.contains(object["name"] as! String) == false {
                                interests.append(object["name"] as! String)
                            }
                        } else {
                            // do nothing
                        }
                    }
                    var interestsString = String()
                    for item in interests {
                        interestsString.append(item)
                        interestsString.append(", ")
                    }
                    interestsString = String(interestsString.characters.dropLast(2))
                    print("interestsstring \(interestsString)")
                    cell.interestedInLabel.text = "Interested in: \(interestsString)"
                }
            }
        }
        
        // get photo
        let queryPhoto = PFQuery(className: "_User")
        queryPhoto.whereKey("username", equalTo: students[indexPath.row])
        queryPhoto.findObjectsInBackground { (objects, error) in
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
                                        cell.imageProfile.image = downloadedImage
                                        cell.imageProfile.layer.cornerRadius = 25
                                        cell.imageProfile.layer.masksToBounds = true
                                    }
                                }
                            }
                        } else {
                            // no image found
                            cell.imageProfile.image = UIImage(named: "profile.png")
                            cell.imageProfile.layer.cornerRadius = 25
                            cell.imageProfile.layer.masksToBounds = true
                            
                        }
                        
                    }
                } else {
                    print("no objects")
                }
            }
        }
        
        /*
        // get abilities
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
        */

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        userSelectedTV = students[indexPath.row]
        performSegue(withIdentifier: "toPotentialMatchSegue", sender: self)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toPotentialMatchSegue") {
            let PotentialVC = segue.destination as! PotentialMatchViewController
            PotentialVC.userSelectedPM = userSelectedTV
        }
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
