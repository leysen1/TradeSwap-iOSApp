//
//  ProfileViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 24/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

var showMySkills = false
var skillDescriptionTitle = ""

/*
 To Do:
 
 Put in activity indicator
 Gender switch and save
 drop down list for neighbourhood and save
 
 */

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var activityIndicator = UIActivityIndicatorView()
    var hasSkillsArray = [String]()
    var wantsSkillsArray = [String]()
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var genderSwitch: UISwitch!

    @IBOutlet var hasSkillsTable: UITableView!
    @IBOutlet var wantsSkillsTable: UITableView!

    
    @IBAction func updateImage(_ sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if 
            let imageProfile = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = imageProfile
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func savePage(_ sender: AnyObject) {
        
        //save image
        let imageData = UIImagePNGRepresentation(profileImage.image!)
        PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData!)
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if error != nil {
                print(error)
            } else {
                print("image saved")
            }
        })
        
        // save gender
        
        
        
    }

    @IBAction func skills(_ sender: AnyObject) {
        showMySkills = true
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "toSkillsSegue", sender: self)
        }

    }
    @IBAction func skillsIWant(_ sender: AnyObject) {
        showMySkills = false
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "toSkillsSegue", sender: self)
        }
    }
    

    func refresh() {
        
        hasSkillsArray.removeAll()
        wantsSkillsArray.removeAll()
        
        let querySkills = PFQuery(className: "Skills")
        querySkills.whereKey("hasSkill", contains: (PFUser.current()?.username!)!)
        querySkills.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            }
            else {
                if let objects = objects {
                    for skill in objects {
                        if let skillHeld = skill["name"] as? String {
                            self.hasSkillsArray.append(skillHeld)
                            self.hasSkillsTable.reloadData()
                           
                        }
                    }
                } else {
                    print("no skills found")
                }
            }
        }
        
        let queryWants = PFQuery(className: "Skills")
        queryWants.whereKey("wantsSkill", contains: (PFUser.current()?.username!)!)
        queryWants.findObjectsInBackground { (objects, error) in
            if error != nil {
                print(error)
            }
            else {
                
                if let objects = objects {
                    for skill in objects {
                        if let skillWants = skill["name"] as? String {
                            self.wantsSkillsArray.append(skillWants)
                            self.wantsSkillsTable.reloadData()
                        }
                    } 
                } else {
                    print("no skill wants found")
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        usernameLabel.text = PFUser.current()?.username
        
        // get saved photo
        if let photo = PFUser.current()?["photo"] as? PFFile {
    
            photo.getDataInBackground(block: { (data, error) in
                
                if let imageData = data {
                    if let downloadedImage = UIImage(data: imageData) {
                        self.profileImage.image = downloadedImage
                    }
                }
                
            })

        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refresh()
        self.hasSkillsTable.tableFooterView = UIView()
        self.wantsSkillsTable.tableFooterView = UIView()
        
    }


    

    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the sample data structure.
        
        if tableView == hasSkillsTable {
            return hasSkillsArray.count
        }
        else {
            return wantsSkillsArray.count
        }

    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        turnSpinnerOn()
        
        if tableView == hasSkillsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = hasSkillsArray[indexPath.row]
            cell.textLabel?.font = UIFont(name: "MarkerFelt-Thin", size: 15)
            turnSpinnerOff()
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = wantsSkillsArray[indexPath.row]
            cell.textLabel?.font = UIFont(name: "MarkerFelt-Thin", size: 15)
            
            turnSpinnerOff()
            return cell
            
        }
        
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSkillDesSegue", sender: nil)
        
        if tableView == hasSkillsTable {
        skillDescriptionTitle = hasSkillsArray[indexPath.row]
        print("located here")
        print(skillDescriptionTitle)
        }
        
    }
    
    func turnSpinnerOn() {
        
        // spinner
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()

    }
    
    func turnSpinnerOff() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
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
