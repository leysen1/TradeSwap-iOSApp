//
//  ProfileViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Charlotte Leysen on 24/10/2016.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

/*
 To Do:
 
 Put in activity indicator
 add another table View Controller, with a checklist of neighbourhoods
 
 */


class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var activityIndicator = UIActivityIndicatorView()
    var showMySkillsPV = false
    var hasSkillsArray = [String]()
    var wantsSkillsArray = [String]()
    var skillDescriptionTitlePV = ""
    var hasSkillTablePV: Bool = true
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var genderSwitch: UISwitch!
    @IBOutlet var bioSkillsLabel: UILabel!

    @IBOutlet var hasSkillsTable: UITableView!
    @IBOutlet var wantsSkillsTable: UITableView!
    
    @IBAction func neighbourhoods(_ sender: AnyObject) {
        
    }
    

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
        
        turnSpinnerOn()
        
        //save image
        let imageData = UIImagePNGRepresentation(profileImage.image!)
        PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData!)
        
        let isFemale = genderSwitch.isOn
        PFUser.current()?["isFemale"] = isFemale
        
        let text = descriptionText.text
        PFUser.current()?["description"] = text
        
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if error != nil {
                print(error)
            } else {
                print("image, gender, and description saved")
            }
        })

        // save area
        // drop down?
        
        self.viewDidLoad()
        
        turnSpinnerOff()
        
        
    }

    @IBAction func skills(_ sender: AnyObject) {
        showMySkillsPV = true
        OperationQueue.main.addOperation {
            [weak self] in
            self?.performSegue(withIdentifier: "toSkillsSegue", sender: self)
        }

    }
    @IBAction func skillsIWant(_ sender: AnyObject) {
        showMySkillsPV = false
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
                        self.profileImage.layer.cornerRadius = 50
                        self.profileImage.layer.masksToBounds = true
                        self.backgroundImage.image = downloadedImage
                    }
                }
            })
        }
        
        // get description and gender
        
        if let text = PFUser.current()?["description"] as? String {
            self.descriptionText.text = text
        }
        if let isFemale = PFUser.current()?["isFemale"] as? Int {
            if isFemale == 1 {
                self.genderSwitch.setOn(true, animated: false)
            } else {
                self.genderSwitch.setOn(false, animated: false)
            }
        }
        // get area
        
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
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 11)
            turnSpinnerOff()
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = wantsSkillsArray[indexPath.row]
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 11)
            
            turnSpinnerOff()
            return cell
            
        }
        
    }

  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == hasSkillsTable {
            self.skillDescriptionTitlePV = hasSkillsArray[indexPath.row]
            hasSkillTablePV = true
            performSegue(withIdentifier: "toSkillDesSegue", sender: nil)
            
        } else {
            // wantsSkillsTable
            self.skillDescriptionTitlePV = wantsSkillsArray[indexPath.row]
            hasSkillTablePV = false
            performSegue(withIdentifier: "toSkillDesSegue", sender: nil)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toSkillDesSegue") {
            let skillDesVC = segue.destination as! SkillDescriptionViewController
            skillDesVC.editMode = true
            skillDesVC.skillDescriptionTitleSD = skillDescriptionTitlePV
            skillDesVC.hasSkillTableSD = hasSkillTablePV
        }
        
        if (segue.identifier == "toSkillsSegue") {
            let skillVC = segue.destination as! SkillsTableViewController
            skillVC.showMySkills = showMySkillsPV
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
